#!/usr/bin/env python3
"""
Build a dependency graph for BLFS packages and their dependencies.

Usage:
    python blfs-deps.py --base-url <BLFS_PACKAGE_URL> \
                        [--output <output.json>] 
"""
import argparse
import json
import logging
import re
import time
from urllib.parse import urljoin

import networkx as nx
import requests
from bs4 import BeautifulSoup

# configure logging
logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

HEADERS = {"User-Agent": "blfs-deps/1.4 (+https://github.com/yourname)"}
SESSION = requests.Session()
SESSION.headers.update(HEADERS)
CACHE = {}


def fetch_page(url, depth=0):
    """Fetch HTML of a URL, with simple caching and retry, indenting log by depth."""
    indent = '  ' * depth
    if url in CACHE:
        logging.info(f"{indent}Cached {url}")
        return CACHE[url]
    logging.info(f"{indent}Fetching {url}")
    resp = SESSION.get(url)
    resp.raise_for_status()
    html = resp.text
    CACHE[url] = html
    time.sleep(0.5)
    return html


def parse_dep_links(html, base_url):
    """
    Locate "Required" and "Recommended" sections, then extract dependency links
    from the next list or paragraph block.
    """
    soup = BeautifulSoup(html, "html.parser")
    deps = set()
    for heading in soup.find_all(re.compile(r"^h[1-6]$")):
        text = heading.get_text(strip=True)
        if not any(k in text for k in ("Required", "Recommended")):
            continue
        # scan siblings until next heading
        for sib in heading.find_next_siblings():
            if sib.name and re.match(r"^h[1-6]$", sib.name):
                break
            if sib.name in ("ul", "ol", "p"):
                for a in sib.find_all('a', href=True):
                    deps.add(urljoin(base_url, a['href']))
                break
    return list(deps)


def extract_metadata(html, url):
    """Extract package name, version, checksum, and download URLs."""
    data = {
        'name': None,
        'version': None,
        'checksum': None,
        'url': None,
        'download_http': None,
    }
    # parse HTML once
    soup = BeautifulSoup(html, 'html.parser')
    # try explicit HTTP download link
    for text_node in soup.find_all(string=re.compile(r"Download\s*\(HTTP\)", re.I)):
        parent = text_node.parent
        a = parent.find('a', href=True)
        if a:
            data['download_http'] = urljoin(url, a['href'])
            break
    # generic download URL fallback
    m_url = re.search(r'(https?://\S+\.(?:tar\.gz|tgz|tar\.bz2|tar\.xz))', html)
    if m_url:
        dl = m_url.group(1)
        data['url'] = dl
        if not data['download_http']:
            data['download_http'] = dl
        fname = dl.split('/')[-1]
        ver = re.sub(r'^.*?-([0-9].*)\.(?:tar\..*|tgz)$', r'\1', fname)
        data['version'] = ver
    # checksums
    m_sha = re.search(r'(?:SHA256\s*\(.*?\)\s*=|Download\s+SHA256\s+sum:)\s*([A-Fa-f0-9]{64})', html)
    if m_sha:
        data['checksum'] = m_sha.group(1)
    else:
        m_md1 = re.search(r'MD5\s*\(.*?\)\s*=\s*([A-Fa-f0-9]{32})', html)
        m_md2 = re.search(r'Download\s+MD5\s+sum:\s*([A-Fa-f0-9]{32})', html)
        if m_md1:
            data['checksum'] = m_md1.group(1)
        elif m_md2:
            data['checksum'] = m_md2.group(1)
        else:
            if data['download_http']:
                fname = data['download_http'].split('/')[-1]
                m_md3 = re.search(r'([A-Fa-f0-9]{32})\s+' + re.escape(fname), html)
                if m_md3:
                    data['checksum'] = m_md3.group(1)
    # infer name
    h1 = soup.find('h1')
    data['name'] = h1.get_text(strip=True) if h1 else url.rstrip('/').split('/')[-1]
    return data


def crawl(base_url):
    """Recursively crawl dependencies and build a DiGraph, logging depth."""
    G = nx.DiGraph()
    to_visit = [(base_url, 0)]
    visited = set()
    while to_visit:
        url, depth = to_visit.pop()
        if url in visited:
            continue
        visited.add(url)
        html = fetch_page(url, depth)
        meta = extract_metadata(html, url)
        G.add_node(url, **meta)
        for dep in parse_dep_links(html, url):
            G.add_edge(url, dep)
            if dep not in visited:
                to_visit.append((dep, depth + 1))
    return G


def export_graph(G, outpath):
    """Export graph to JSON array with node metadata and deps."""
    data = []
    for url, meta in G.nodes(data=True):
        data.append({
            'url': url,
            'name': meta.get('name'),
            'version': meta.get('version'),
            'checksum': meta.get('checksum'),
            'download_http': meta.get('download_http'),
            'deps': list(G.successors(url)),
        })
    with open(outpath, 'w') as f:
        json.dump(data, f, indent=2)
    logging.info(f"Graph exported to {outpath}")


def main():
    parser = argparse.ArgumentParser(description="BLFS deps crawler")
    parser.add_argument('--base-url', required=True, help='BLFS package URL')
    parser.add_argument('--output', default='deps.json', help='Output JSON')
    args = parser.parse_args()
    G = crawl(args.base_url)
    export_graph(G, args.output)

if __name__ == '__main__':
    main()

