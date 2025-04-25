#!/usr/bin/env python3
"""
BLFS Dependency Graph Builder — parallel, persistent cache, thread-safe

Usage:
    python blfs-deps.py --base-url <BLFS_PACKAGE_URL> \
                        [--output deps.json] \
                        [--only-required | --only-recommended] \
                        [--exclude <Pkg> ...] \
                        [--dot graph.dot] \
                        [--workers 12] [--delay 0.3]
"""

import argparse, json, logging, re, time, threading, atexit, contextlib
from concurrent.futures import ThreadPoolExecutor, as_completed
from typing import cast
from urllib.parse import urljoin

import requests_cache, networkx as nx
from bs4 import BeautifulSoup, Tag

# ─── logging ────────────────────────────────────────────────────────────────
logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

# ─── HTTP session (thread-local CachedSession) ──────────────────────────────
HEADERS = {"User-Agent": "blfs-deps/1.9 (+https://github.com/yourname)"}
_thread_local = threading.local()
_sessions: set[requests_cache.CachedSession] = set()        # for clean exit

def get_session() -> requests_cache.CachedSession:
    if not hasattr(_thread_local, "session"):
        sess = requests_cache.CachedSession(
            "blfs_cache", backend="sqlite", fast_save=True,
            expire_after=7 * 24 * 60 * 60, stale_if_error=True,
            allowable_codes=(200, 203, 300),
        )
        sess.headers.update(HEADERS)
        _thread_local.session = sess
        _sessions.add(sess)
    return _thread_local.session

@atexit.register
def _close():
    for s in list(_sessions):
        with contextlib.suppress(Exception):
            s.close()

# ─── globals ────────────────────────────────────────────────────────────────
CACHE: dict[str, str] = {}           # in-process HTML cache
visited: set[str] = set()
LOCK = threading.Lock()              # guards 'visited'

# sha/md5 regexes (case-insensitive, flexible spacing/colon)
CHECK_PATTERNS = [
    re.compile(r'(?:SHA256\s*\(.*?\)\s*=|Download\s+SHA256\s+Sum:?)\s*([A-Fa-f0-9]{64})', re.I),
    re.compile(r'(?:MD5\s*\(.*?\)\s*=|Download\s+MD5\s+Sum:?)\s*([A-Fa-f0-9]{32})', re.I),
]

# archive URL extractor
ARCHIVE_RE = re.compile(
    r'https?://[^\s"\'<>]+?\.(?:'
    r'tar\.(?:gz|bz2|xz|lz|zst)|'        # *.tar.{gz,bz2,xz,lz,zst}
    r't(?:gz|bz2|xz)|'                   # *.tgz, *.tbz2, *.txz
    r'(?:zip|gz|xz|bz2))',               # bare .zip/.gz/.xz/.bz2
    re.I,
)

# ─── helpers ────────────────────────────────────────────────────────────────
def fetch_page(url: str, depth: int = 0) -> tuple[str, bool]:
    indent = "  " * depth
    if url in CACHE:
        logging.info(f"{indent}Cached-mem {url}")
        return CACHE[url], True
    sess = get_session()
    try:
        resp = sess.get(url)
        resp.raise_for_status()
        hit = getattr(resp, "from_cache", False)
        logging.info(f"{indent}{'Cache-hit' if hit else 'Fetching '} {url}")
        html = resp.text
        CACHE[url] = html
        return html, hit
    except Exception as e:
        logging.error(f"{indent}Failed {url}: {e}")
        return "", False

def parse_dep_links(html: str, base_url: str,
                    only_recommended=False, only_required=False) -> list[str]:
    try:
        soup = BeautifulSoup(html, "html.parser")
    except Exception as e:
        logging.error(f" Dependency parse failed for {base_url}: {e}")
        return []
    deps: set[str] = set()
    for h in soup.find_all(re.compile(r"^h[1-6]$")):
        text = h.get_text(strip=True)
        if only_recommended and "Recommended" not in text:  continue
        if only_required   and "Required"    not in text:   continue
        if not (only_required or only_recommended) and \
           not any(k in text for k in ("Required", "Recommended")):
            continue
        for sib in h.find_next_siblings():
            if not isinstance(sib, Tag):
                continue
            if sib.name and re.match(r"^h[1-6]$", sib.name):
                break
            if sib.name in ("ul", "ol", "p"):
                for a in sib.find_all("a", href=True):
                    href = a.get("href")
                    if href:
                        deps.add(urljoin(base_url, cast(str, href)))
                break
    return list(deps)

def extract_metadata(html: str, url: str) -> dict:
    data = {"name": url.rstrip("/").split("/")[-1], "version": None,
            "checksum": None, "url": url, "download_http": None}
    try:
        soup = BeautifulSoup(html, "html.parser")
        if (h1 := soup.find("h1")):
            data["name"] = h1.get_text(strip=True)

        if (m_url := ARCHIVE_RE.search(html)):
            dl = m_url.group(0)
            data["download_http"] = dl
            if (vm := re.search(r'-([0-9A-Za-z.+_-]+)\.(?:tar|t[bg]z2?|zip|xz|gz|bz2)', dl)):
                data["version"] = vm.group(1)

        for pat in CHECK_PATTERNS:
            if (m := pat.search(html)):
                data["checksum"] = m.group(1); break
    except Exception as e:
        logging.error(f"⚠️  Metadata parse failed for {url}: {e}")
    return data

# ─── crawler ────────────────────────────────────────────────────────────────
def crawl(base_url: str, *, workers=12, delay=0.3,
          only_recommended=False, only_required=False, exclude_packages=None):
    G, to_visit = nx.DiGraph(), [base_url]
    with LOCK: visited.add(base_url)
    with ThreadPoolExecutor(max_workers=workers) as pool:
        while to_visit:
            batch, to_visit = to_visit[:workers], to_visit[workers:]
            futs = {pool.submit(fetch_page, url): url for url in batch}
            if any(not hit for _, hit in (f.result() for f in futs)): time.sleep(delay)
            for fut in as_completed(futs):
                url, html = futs[fut], fut.result()[0]
                if not html: continue
                meta = extract_metadata(html, url)
                if exclude_packages and meta["name"] in (exclude_packages or []): continue
                G.add_node(url, **meta)
                for dep in parse_dep_links(html, url,
                                           only_recommended, only_required):
                    G.add_edge(url, dep)
                    with LOCK:
                        if dep not in visited: visited.add(dep); to_visit.append(dep)
    return G

# ─── export helpers ─────────────────────────────────────────────────────────
def export_graph(G: nx.DiGraph, path: str):
    data = [{**meta,
             "deps": [G.nodes[d].get("name") for d in G.successors(url)]}
            for url, meta in G.nodes(data=True)]
    with open(path, "w") as f: json.dump(data, f, indent=2)
    logging.info(f"✅ Wrote {path}")

def export_dot(G: nx.DiGraph, path="graph.dot"):
    nx.drawing.nx_pydot.write_dot(G, path); logging.info(f"📈 Wrote {path}")

# ─── CLI ────────────────────────────────────────────────────────────────────
def main():
    p = argparse.ArgumentParser(description="BLFS Dependency Crawler")
    p.add_argument("--base-url", required=True)
    p.add_argument("--output", default="deps.json")
    grp = p.add_mutually_exclusive_group()
    grp.add_argument("--only-recommended", action="store_true")
    grp.add_argument("--only-required",   action="store_true")
    p.add_argument("--exclude", nargs="*"); p.add_argument("--dot")
    p.add_argument("--workers", type=int, default=12)
    p.add_argument("--delay",   type=float, default=0.3)
    args = p.parse_args()

    G = crawl(args.base_url, workers=args.workers, delay=args.delay,
              only_recommended=args.only_recommended,
              only_required=args.only_required,
              exclude_packages=args.exclude)
    export_graph(G, args.output);  export_dot(G, args.dot) if args.dot else None

if __name__ == "__main__":
    main()

