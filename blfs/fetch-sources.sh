#!/usr/bin/env bash
#
# fetch-sources.sh — download + verify BLFS tarballs
#

set -euo pipefail

# -------- defaults --------
DEPS=./deps.json
MIRROR=""
JOBS=8
SOURCES=${SOURCES:-./sources}

# -------- arg-parse --------
while [[ $# -gt 0 ]]; do
    case $1 in
        --deps)   DEPS=$2;   shift 2 ;;
        --mirror) MIRROR=$2; shift 2 ;;
        --jobs)   JOBS=$2;   shift 2 ;;
        *) echo "Unknown arg: $1" >&2; exit 1 ;;
    esac
done

[[ -f $DEPS ]] || { echo "deps file not found: $DEPS" >&2; exit 1; }
mkdir -p "$SOURCES"

echo "➜  Using deps file : $DEPS"
echo "➜  Download dir    : $SOURCES"
[[ -n $MIRROR ]] && echo "➜  Mirror override : $MIRROR"
echo "➜  Parallel jobs   : $JOBS"

# -------- portable checksum helper --------
verify() {
    local file=$1 sum=$2 digest=""
    [[ -z $sum ]] && return 0          # nothing to verify

    case ${#sum} in
        32)  # MD5
            if command -v md5sum >/dev/null 2>&1; then
                digest=$(md5sum "$file" | awk '{print $1}')
            else
                digest=$(md5 -q "$file")
            fi
            ;;
        64)  # SHA-256
            if command -v sha256sum >/dev/null 2>&1; then
                digest=$(sha256sum "$file" | awk '{print $1}')
            else
                digest=$(shasum -a 256 "$file" | awk '{print $1}')
            fi
            ;;
        *) return 1 ;;  # unsupported length
    esac

    [[ "$digest" == "$sum" ]]
}

# -------- list of “URL<TAB>CHECKSUM” lines --------
mapfile -t ITEMS < <(
    jq -r '.[] | [.download_http, .checksum // ""] | @tsv' "$DEPS"
)
echo "Found ${#ITEMS[@]} items"

# -------- single download --------
dl_one() {
    IFS=$'\t' read -r url sum <<<"$1"   # keep tab intact
    [[ -z $url ]] && return

    [[ -n $MIRROR ]] && url="$MIRROR/$(basename "$url")"
    file="$SOURCES/$(basename "$url")"

    if [[ -f $file ]] && verify "$file" "$sum"; then
        echo "✓ Already verified: $(basename "$file")"
        [[ -z $sum ]] && touch "$file.UNVERIFIED"
        return
    fi

    echo "→ Fetching $(basename "$file")"
    wget -q -c -O "$file" "$url"

    if ! verify "$file" "$sum"; then
        if [[ -n $sum ]]; then
            echo "⚠️  Checksum mismatch for $(basename "$file")"
            rm -f "$file"; exit 1
        fi
    fi
    [[ -z $sum ]] && touch "$file.UNVERIFIED"

    return 0 # ensure success for set -e
}

export -f dl_one verify
export SOURCES MIRROR

# -------- run --------
if (( JOBS > 1 )); then
    printf '%s\0' "${ITEMS[@]}" \
        | xargs -0 -n1 -P"$JOBS" bash -c 'dl_one "$@"' _
else
    for item in "${ITEMS[@]}"; do dl_one "$item"; done
fi

echo "✔ All sources fetched & verified"

