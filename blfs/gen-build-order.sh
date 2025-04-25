#!/usr/bin/env bash
#
#  gen-build-order.sh — output build-order.txt from deps.json
#
#  Small runtime cycles (A↔B) are broken automatically: whichever package is
#  encountered first in the SCC is kept, the reverse edge is ignored.
#

set -euo pipefail

DEPS=./deps.json
OUT=build-order.txt

while [[ $# -gt 0 ]]; do
  case $1 in
    --deps) DEPS=$2; shift 2 ;;
    --out)  OUT=$2;  shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

[[ -f $DEPS ]] || { echo "deps file not found: $DEPS" >&2; exit 1; }

python3 - "$DEPS" "$OUT" <<'PY'
import json, re, sys, itertools
from collections import defaultdict, deque
from graphlib import TopologicalSorter, CycleError

deps_file, out_file = sys.argv[1:3]
pkgs = json.load(open(deps_file))

# --- build graph -----------------------------------------------------------
name2deps = {p["name"]: set(p.get("deps", [])) for p in pkgs}

# drop edges that point to packages we don't know about
all_names = set(name2deps)
for n, ds in list(name2deps.items()):
    name2deps[n] = {d for d in ds if d in all_names and d != n}

# --- break tiny runtime cycles (size ≤ 4) ----------------------------------
def strongly_connected(graph):
    """Kosaraju SCCs."""
    order, seen = [], set()
    def dfs(v):
        seen.add(v)
        for w in graph[v]:
            if w not in seen: dfs(w)
        order.append(v)
    for v in graph:
        if v not in seen: dfs(v)

    rev = defaultdict(set)
    for u, vs in graph.items():
        for v in vs: rev[v].add(u)

    comp, seen2 = [], set()
    def dfs2(v, bucket):
        seen2.add(v); bucket.add(v)
        for w in rev[v]:
            if w not in seen2: dfs2(w, bucket)

    for v in reversed(order):
        if v not in seen2:
            bucket=set(); dfs2(v,bucket); comp.append(bucket)
    return comp

for scc in strongly_connected(name2deps):
    if len(scc) <= 4 and len(scc) > 1:
        # keep first node, drop back-edges inside SCC
        root = next(iter(scc))
        for n in scc:
            if n is root: continue
            name2deps[n].discard(root)

# --- topological sort ------------------------------------------------------
ts = TopologicalSorter(name2deps)
try:
    build_order = list(ts.static_order())
except CycleError as err:
    print("❌ Residual cycle in graph:", *err.args, file=sys.stderr)
    sys.exit(1)

# --- write list of build-script filenames ----------------------------------
def slugify(n:str)->str:
    return re.sub(r'[^A-Za-z0-9]+','-',n).strip('-').lower()

with open(out_file,"w") as f:
    for n in build_order:
        f.write(f"build/{slugify(n)}.sh\n")

print(f"✔ build order written to {out_file} ({len(build_order)} packages)")
PY

