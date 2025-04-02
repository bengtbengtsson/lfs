#!/bin/bash

set -euo pipefail

export LFS=/mnt/lfs
SOURCES="$LFS/sources"

echo "### Ensuring sources directory exists and is writable"
mkdir -pv "$SOURCES"
chmod -v a+wt "$SOURCES"

echo "### Downloading source files"
wget --input-file=wget-list-sysv \
     --continue \
     --directory-prefix="$SOURCES" \
     --no-verbose \
     --show-progress

echo "### Verifying all expected files are present"

missing_files=()

while read -r hash filename; do
    if [[ ! -f "$SOURCES/$filename" ]]; then
        missing_files+=("$filename")
    fi
done < md5sums

if (( ${#missing_files[@]} > 0 )); then
    echo "❌ Missing file(s) after wget:"
    printf '  - %s\n' "${missing_files[@]}"
    echo "Aborting."
    exit 1
fi

echo "### Copying md5sums to sources"
cp -v md5sums "$SOURCES"

echo "### Verifying checksums"
pushd "$SOURCES" > /dev/null
md5sum -c md5sums
popd > /dev/null

echo "### Fixing file ownership"
chown root:root "$SOURCES"/*

