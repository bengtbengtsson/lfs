#!/usr/bin/env python3
"""
BLFS Dependency Graph Builder with Required/Recommended Filtering

Usage:
    python blfs-deps.py --base-url <BLFS_PACKAGE_URL> \
                        [--output deps.json] \
                        [--only-required | --only-recommended] \
                        [--exclude <Package1> ...] \
                        [--dot graph.dot]
"""

import argparse
import json
import logging
import re
import time
from urllib.parse import urljoin

import networkx as nx
import requests
from bs4 import BeautifulSoup, Tag
from typing import cast

# Logging config
logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

HEADERS = {"User-Agent": "blfs-deps/1.6 (+https://github.com/yourname)"}
SESSION = requests.Session()
SESSION.headers.update(HEADERS)
CACHE = {}
visited = set()

def fetch_page(url, depth=0):
    indent = '  ' * depth
    if url in CACHE:
        logging.info(f"{indent}Cached {url}")
        return CACHE[url]
    try:
        logging.info(f"{indent}Fetching {url}")
        resp = SESSION.get(url)
        resp.raise_for_status()
        html = resp.text
        CACHE[url] = html
        time.sleep(0.3)
        return html
    except requests.RequestException as e:
        logging.error(f"{indent}Failed to fetch {url}: {e}")
        return ""

def parse_dep_links(html: str, base_url: str, only_recommended: bool = False, only_required: bool = False) -> list[str]:
    soup: BeautifulSoup = BeautifulSoup(html, "html.parser")
    deps: set[str] = set()

    for heading in soup.find_all(re.compile(r"^h[1-6]$")):
        if not isinstance(heading, Tag):
            continue

        text = heading.get_text(strip=True)
        if only_recommended and "Recommended" not in text:
            continue
        if only_required and "Required" not in text:
            continue
        if not (only_required or only_recommended) and not any(k in text for k in ("Required", "Recommended")):
            continue

        for sib in heading.find_next_siblings():
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

def extract_metadata(html, url):
    data = {
        'name': None,
        'version': None,
        'checksum': None,
        'url': url,
        'download_http': None,
    }
    soup = BeautifulSoup(html, 'html.parser')
    h1 = soup.find('h1')
    data['name'] = h1.get_text(strip=True) if h1 else url.rstrip('/').split('/')[-1]

    m_url = re.search(r'(https?://\S+\.(?:tar\.\w+|tgz))', html)
    if m_url:
        dl = m_url.group(1)
        data['download_http'] = dl

    # Attempt to extract a checksum
    patterns = [
        r'(?:SHA256\s*\(.*?\)\s*=|Download SHA256 sum:)\s*([A-Fa-f0-9]{64})',
        r'(?:MD5\s*\(.*?\)\s*=|Download MD5 sum:)\s*([A-Fa-f0-9]{32})',
    ]
    for pat in patterns:
        match = re.search(pat, html)
        if match:
            data['checksum'] = match.group(1)
            break

    return data

def crawl(base_url, only_recommended=False, only_required=False, exclude_packages=None):
    G = nx.DiGraph()
    to_visit = [(base_url, 0)]

    while to_visit:
        url, depth = to_visit.pop()
        if url in visited:
            continue
        visited.add(url)

        html = fetch_page(url, depth)
        if not html:
            continue

        meta = extract_metadata(html, url)
        if exclude_packages and meta['name'] in exclude_packages:
            logging.info(f"⏭️ Skipping excluded package: {meta['name']}")
            continue

        G.add_node(url, **meta)
        deps = parse_dep_links(html, url,
                               only_recommended=only_recommended,
                               only_required=only_required)
        for dep in deps:
            G.add_edge(url, dep)
            if dep not in visited:
                to_visit.append((dep, depth + 1))
    return G

def export_graph(G, outpath):
    data = []
    for url, meta in G.nodes(data=True):
        data.append({
            'name': meta.get('name'),
            'version': meta.get('version'),
            'checksum': meta.get('checksum'),
            'download_http': meta.get('download_http'),
            'url': url,
            'deps': [G.nodes[d].get('name') for d in G.successors(url)],
        })
    with open(outpath, 'w') as f:
        json.dump(data, f, indent=2)
    logging.info(f"✅ Dependency graph exported to {outpath}")

def export_dot(G, path="graph.dot"):
    nx.drawing.nx_pydot.write_dot(G, path)
    logging.info(f"📈 Graphviz DOT exported to {path}")

def main():
    parser = argparse.ArgumentParser(description="BLFS Dependency Crawler")
    parser.add_argument('--base-url', required=True, help='Starting URL (e.g. Xorg)')
    parser.add_argument('--output', default='deps.json', help='JSON output file')

    group = parser.add_mutually_exclusive_group()
    group.add_argument('--only-recommended', action='store_true', help='Only follow Recommended deps')
    group.add_argument('--only-required', action='store_true', help='Only follow Required deps')

    parser.add_argument('--exclude', nargs='*', help='List of packages to exclude by name')
    parser.add_argument('--dot', help='Optional output path for DOT graph')

    args = parser.parse_args()
    G = crawl(
        base_url=args.base_url,
        only_recommended=args.only_recommended,
        only_required=args.only_required,
        exclude_packages=args.exclude
    )
    export_graph(G, args.output)
    if args.dot:
        export_dot(G, args.dot)

if __name__ == '__main__':
    main()

