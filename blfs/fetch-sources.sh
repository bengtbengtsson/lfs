#!/usr/bin/env bash
#
#  fetch-sources.sh — download & verify BLFS tarballs
#
#  Usage:
#      ./fetch-sources.sh [--deps deps.json] [--mirror URL] [--jobs 8]
#
#  Environment:
#      SOURCES  : destination directory (default: ./sources)
#

set -euo pipefail

# ─── defaults ──────────────────────────────────────────────────────────────
DEPS=./deps.json
MIRROR=""
JOBS=8
SOURCES=${SOURCES:-./sources}

# ─── argument parsing ──────────────────────────────────────────────────────
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

# ─── portable checksum verifier ────────────────────────────────────────────
verify() {
    local file=$1 want=$2 got
    [[ -z $want ]] && return 0          # nothing to verify

    case ${#want} in
        64)  # SHA-256
            if command -v sha256sum >/dev/null 2>&1; then
                got=$(sha256sum "$file" | awk '{print $1}')
            else
                got=$(shasum -a 256 "$file" | awk '{print $1}')
            fi ;;
        32)  # MD5
            if command -v md5sum >/dev/null 2>&1; then
                got=$(md5sum "$file" | awk '{print $1}')
            else
                got=$(md5 -q "$file")
            fi ;;
        *)   return 1 ;; # unsupported
    esac
    [[ $got == "$want" ]]
}

# ─── build “URL<TAB>CHECKSUM” list, skipping meta pkgs & dups ──────────────
mapfile -t ITEMS < <(
    jq -r '
        map(select(.download_http != null))
        | unique_by(.download_http)
        | .[] | [.download_http, .checksum // ""] | @tsv
    ' "$DEPS"
)
echo "Found ${#ITEMS[@]} unique tarballs"

# ─── downloader ────────────────────────────────────────────────────────────
dl_one() {
    IFS=$'\t' read -r url sum <<<"$1"
    [[ -z $url ]] && return 0           # safety

    [[ -n $MIRROR ]] && url="$MIRROR/$(basename "$url")"
    file="$SOURCES/$(basename "$url")"

    if [[ -f $file ]] && verify "$file" "$sum"; then
        echo "✓ Already verified: $(basename "$file")"
        [[ -z $sum ]] && touch "$file.UNVERIFIED"
        return 0
    fi

    echo "→ Fetching $(basename "$file")"
    wget -q -c -O "${file}.part" "$url"
    if [[ $? -ne 0 ]]; then                       # ⬅️ download error?
        echo "⚠️  Download failed: $(basename "$file")"
        rm -f "${file}.part"                      # clean partial
        return 1                                  # skip checksum step
    fi
    mv -f "${file}.part" "$file"

    if ! verify "$file" "$sum"; then
        if [[ -n $sum ]]; then
            echo "⚠️  Checksum mismatch: $(basename "$file")"
            rm -f "$file"; exit 1
        fi
    fi
    [[ -z $sum ]] && touch "$file.UNVERIFIED"
    return 0
}

export -f dl_one verify
export SOURCES MIRROR

# ─── run (parallel or serial) ──────────────────────────────────────────────
if (( JOBS > 1 )); then
    printf '%s\0' "${ITEMS[@]}" \
        | xargs -0 -n1 -P"$JOBS" bash -c 'dl_one "$@"' _
else
    for item in "${ITEMS[@]}"; do dl_one "$item"; done
fi

echo "✔ All sources fetched & verified"

