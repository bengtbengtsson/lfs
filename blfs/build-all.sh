#!/usr/bin/env bash
#
# build-all.sh — build all packages listed in build-order.txt
#

set -euo pipefail

BUILD_ORDER=${1:-build-order.txt}
LOGDIR=logs
SUMMARY=${SUMMARY:-1}   # Set SUMMARY=0 to disable

mkdir -p "$LOGDIR"

echo "📋 Starting full build based on $BUILD_ORDER"
echo "🗂  Logs will be saved to $LOGDIR/"

FAILED=()

while IFS= read -r script; do
    [[ -z $script ]] && continue
    pkg=$(basename "$script" .sh)
    log="$LOGDIR/${pkg}.log"

    echo "🚀 Building $pkg ..."
    if bash "$script" >"$log" 2>&1; then
        echo "✅ Success: $pkg"
    else
        echo "❌ Failure: $pkg (see $log)"
        FAILED+=("$pkg")
    fi
done < "$BUILD_ORDER"

# ─── Summary ────────────────────────────────────────────────────────────────
if [[ "$SUMMARY" -eq 1 ]]; then
    echo
    echo "📜 Build Summary"
    echo "──────────────────────────────────────────────────"
    if [[ ${#FAILED[@]} -eq 0 ]]; then
        echo "🎉 All packages built successfully!"
    else
        echo "❌ Failed packages:"
        for pkg in "${FAILED[@]}"; do
            echo "   - $pkg"
        done
        exit 1
    fi
fi

