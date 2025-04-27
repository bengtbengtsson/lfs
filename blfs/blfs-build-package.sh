#!/usr/bin/env bash
#
# blfs-build-package.sh — all-in-one BLFS package builder
#

set -euo pipefail

URL="$1"
OUTDIR="build"
DEPS="deps.json"
ORDER="build-order.txt"
LOGDIR="logs"

# ─── Config ─────────────────────────────────────────────────────────────────
JOBS=8
MODEL="deepseek-coder-v2"
OLLAMA_URL="http://localhost:11434"

# ─── Checks ─────────────────────────────────────────────────────────────────
[[ -z "$URL" ]] && { echo "Usage: $0 <BLFS_PACKAGE_URL>"; exit 1; }

echo "🚀 Building from BLFS page: $URL"
echo

# ─── 1. Generate deps.json ──────────────────────────────────────────────────
echo "🔎 Generating dependency list..."
python3 blfs-deps.py --base-url "$URL" --output "$DEPS"

# ─── 2. Fetch sources ───────────────────────────────────────────────────────
echo "📦 Fetching source tarballs..."
./fetch-sources.sh --deps "$DEPS" --jobs "$JOBS"

# ─── 3. Generate build order ─────────────────────────────────────────────────
echo "🧩 Generating build order..."
./gen-build-order.sh --deps "$DEPS" --out "$ORDER"

# ─── 4. Generate build scripts ──────────────────────────────────────────────
echo "🛠️  Generating build scripts..."
python3 gen-build-scripts.py --deps "$DEPS" --outdir "$OUTDIR" --model "$MODEL" --ollama-url "$OLLAMA_URL"

# ─── 5. Build all ────────────────────────────────────────────────────────────
echo "🏗️  Starting full build!"
./build-all.sh "$ORDER"

echo
echo "🎉 Done!"

