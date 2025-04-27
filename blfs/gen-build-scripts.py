#!/usr/bin/env python3
"""
gen-build-scripts.py ─ generate BLFS-style bash build scripts with Ollama,
injecting the exact ‘Installation of …’ commands scraped from the BLFS book.
"""

import argparse
import json
import os
import re
import sys
import textwrap
from typing import Optional

import bs4
import requests

# ────────── CLI ──────────
cli = argparse.ArgumentParser()
cli.add_argument("--deps", nargs="?", default="deps.json")
cli.add_argument("--model", default="deepseek-coder-v2")
cli.add_argument("--outdir", default="build")
cli.add_argument("--ollama-url", default="http://localhost:11434")
cli.add_argument("--timeout", type=int, default=600, help="LLM timeout (s)")
args = cli.parse_args()

os.makedirs(args.outdir, exist_ok=True)
packages = json.load(open(args.deps))
session   = requests.Session()           # keep-alive

# ────────── PROMPT ──────────
HEAD = textwrap.dedent("""
    You are an expert BLFS packager. Output **one** bash build script that
    follows the BLFS style (pushd / popd banner, clean-up).

      • first line '#!/bin/bash', second line 'set -euo pipefail'
      • define   SOURCES=/scripts/blfs/sources/
      • **never** download or checksum – tarballs are pre-fetched
      • use the exact command sequence given below (no re-ordering)
      • after the build step run the proper install command
      • delete the extracted build directory at the end (rm -rf …)
      • finish with:  echo "Done installing {pkg}"
""").strip()

FOOT = "Return only the script – no commentary, no markdown fences."

# ────────── helpers ──────────
def slugify(txt: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", txt.lower()).strip("-")

def fetch_install_block(blfs_url: str) -> Optional[str]:
    try:
        html = session.get(blfs_url, timeout=30).text
        soup = bs4.BeautifulSoup(html, "html.parser")
        hdr  = soup.find(string=re.compile(r"Installation of", re.I))
        pre  = hdr.find_next("pre") if hdr else None
        return pre.get_text("\n", strip=True) if pre else None
    except Exception as e:
        print(f"⚠️  scrape failed for {blfs_url}: {e}", file=sys.stderr)
        return None

def ollama(prompt: str) -> str:
    r = session.post(
        f"{args.ollama_url}/api/generate",
        json={"model": args.model, "prompt": prompt, "stream": False},
        timeout=args.timeout,
    )
    r.raise_for_status()
    data = r.json()
    if "response" not in data:
        raise RuntimeError(f"Ollama JSON missing 'response': {data}")
    return data["response"]

def strip_fences(txt: str) -> str:
    txt = txt.strip()
    if txt.startswith("```"):
        body = txt.splitlines()[1:]
        if body and body[-1].strip().startswith("```"):
            body = body[:-1]
        txt = "\n".join(body)
    return txt.rstrip() + "\n"

def valid_shebang(code: str) -> bool:
    for line in code.splitlines():
        if line.strip():
            return line.lstrip().startswith("#!/bin/bash")
    return False

def has_install_and_cleanup(code: str) -> bool:
    """Accept any script that runs *install* then removes the build tree."""
    install_ok = bool(re.search(r"\b(make|ninja|meson)\b.*\binstall\b", code, re.I))
    cleanup_ok = bool(re.search(r"\brm\s+-rf\s+\S+", code, re.I))
    return install_ok and cleanup_ok

# ────────── main loop ──────────
for pkg in packages:
    src_url = pkg.get("download_http")
    if not src_url:            # meta package
        continue

    name     = pkg["name"]
    version  = pkg.get("version") or "unknown"
    out_path = os.path.join(args.outdir, f"{slugify(name)}.sh")
    if os.path.exists(out_path):
        print(f"✓ cached {name}")
        continue

    install_block = fetch_install_block(pkg["url"]) or ""
    prompt = "\n".join(
        [
            HEAD.format(pkg=name),
            f"\nPackage : {name}-{version}",
            f"Source  : {src_url}",
            "",
            ("Follow these commands exactly:\n" + install_block) if install_block else "",
            FOOT,
        ]
    )

    try:
        raw = ollama(prompt)
    except Exception as e:
        print(f"⚠️  {name}: LLM error – {e}")
        continue

    script = strip_fences(raw)
    if not valid_shebang(script):
        print(f"⚠️  {name}: missing shebang – skipped")
        continue
    if not has_install_and_cleanup(script):
        print(f"⚠️  {name}: missing install/cleanup – skipped")
        continue

    with open(out_path, "w") as f:
        f.write(script)

    print(f"→ wrote {out_path}")

print("✔ build-script generation pass complete")

