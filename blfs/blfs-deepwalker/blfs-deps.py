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

# ---------- logging ----------
logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

# ---------- thread-local CachedSession ----------
HEADERS = {"User-Agent": "blfs-deps/1.8 (+https://github.com/yourname)"}
_thread_local = threading.local()
_sessions: set[requests_cache.CachedSession] = set()   # for clean shutdown

def get_session() -> requests_cache.CachedSession:
    """Return a thread-local CachedSession (sqlite backend)."""
    if not hasattr(_thread_local, "session"):
        sess = requests_cache.CachedSession(
            "blfs_cache",                # blfs_cache.sqlite in cwd
            backend="sqlite",
            fast_save=True,              # batch disk writes
            expire_after=7 * 24 * 60 * 60,   # 1 week
            allowable_codes=(200, 203, 300),
            stale_if_error=True,
        )
        sess.headers.update(HEADERS)
        _thread_local.session = sess
        _sessions.add(sess)
    return _thread_local.session

@atexit.register
def _close_sessions():
    for s in list(_sessions):
        with contextlib.suppress(Exception):
            s.close()

# ---------- globals ----------
CACHE: dict[str, str] = {}   # in-process HTML cache
visited: set[str] = set()
LOCK = threading.Lock()      # guards 'visited'

# ---------- helpers ----------
def fetch_page(url: str, depth: int = 0) -> tuple[str, bool]:
    """Return (html, from_cache_flag)."""
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
                    *, only_recommended=False, only_required=False) -> list[str]:
    soup = BeautifulSoup(html, "html.parser")
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
                    if isinstance(a, Tag):
                        href = a.get("href")
                        if href:
                            deps.add(urljoin(base_url, cast(str, href)))
                break
    return list(deps)

def extract_metadata(html: str, url: str) -> dict:
    data = {"name": None, "version": None, "checksum": None,
            "url": url, "download_http": None}
    soup = BeautifulSoup(html, "html.parser")
    h1 = soup.find("h1")
    data["name"] = h1.get_text(strip=True) if h1 else url.rstrip("/").split("/")[-1]

    m_url = re.search(r"(https?://\S+\.(?:tar\.\w+|tgz))", html)
    if m_url:
        dl = m_url.group(1)
        data["download_http"] = dl
        vm = re.search(r"-([0-9][^-/]*)\.tar", dl)
        if vm:
            data["version"] = vm.group(1)

    for pat in (r"(?:SHA256\s*\(.*?\)\s*=|Download SHA256 sum:)\s*([A-Fa-f0-9]{64})",
                r"(?:MD5\s*\(.*?\)\s*=|Download MD5 sum:)\s*([A-Fa-f0-9]{32})"):
        m = re.search(pat, html)
        if m:
            data["checksum"] = m.group(1)
            break
    return data

# ---------- crawler ----------
def crawl(base_url: str, *, workers=12, delay=0.3,
          only_recommended=False, only_required=False, exclude_packages=None):
    G = nx.DiGraph()
    to_visit = [base_url]
    with LOCK:
        visited.add(base_url)

    with ThreadPoolExecutor(max_workers=workers) as pool:
        while to_visit:
            batch, to_visit = to_visit[:workers], to_visit[workers:]
            fut_map = {pool.submit(fetch_page, url): url for url in batch}

            # delay only if at least one net fetch occurred
            if any(not hit for _, hit in (f.result() for f in fut_map)):
                time.sleep(delay)

            for fut in as_completed(fut_map):
                url = fut_map[fut]
                html, _ = fut.result()
                if not html:
                    continue

                meta = extract_metadata(html, url)
                if exclude_packages and meta["name"] in exclude_packages:
                    logging.info(f"⏭️ Skip {meta['name']}")
                    continue
                G.add_node(url, **meta)

                deps = parse_dep_links(html, url,
                                       only_recommended=only_recommended,
                                       only_required=only_required)
                for dep in deps:
                    G.add_edge(url, dep)
                    with LOCK:
                        if dep not in visited:
                            visited.add(dep)
                            to_visit.append(dep)
    return G

# ---------- export ----------
def export_graph(G: nx.DiGraph, path: str):
    data = []
    for url, meta in G.nodes(data=True):
        data.append({
            "name": meta.get("name"),
            "version": meta.get("version"),
            "checksum": meta.get("checksum"),
            "download_http": meta.get("download_http"),
            "url": url,
            "deps": [G.nodes[d].get("name") for d in G.successors(url)],
        })
    with open(path, "w") as f:
        json.dump(data, f, indent=2)
    logging.info(f"✅ Wrote {path}")

def export_dot(G: nx.DiGraph, path="graph.dot"):
    nx.drawing.nx_pydot.write_dot(G, path)
    logging.info(f"📈 Wrote {path}")

# ---------- CLI ----------
def main():
    p = argparse.ArgumentParser(description="BLFS Dependency Crawler")
    p.add_argument("--base-url", required=True)
    p.add_argument("--output", default="deps.json")
    g = p.add_mutually_exclusive_group()
    g.add_argument("--only-recommended", action="store_true")
    g.add_argument("--only-required",   action="store_true")
    p.add_argument("--exclude", nargs="*")
    p.add_argument("--dot")
    p.add_argument("--workers", type=int, default=12)
    p.add_argument("--delay",   type=float, default=0.3)
    args = p.parse_args()

    G = crawl(args.base_url, workers=args.workers, delay=args.delay,
              only_recommended=args.only_recommended,
              only_required=args.only_required,
              exclude_packages=args.exclude)

    export_graph(G, args.output)
    if args.dot:
        export_dot(G, args.dot)

if __name__ == "__main__":
    main()

