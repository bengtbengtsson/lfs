#!/bin/bash
set -euo pipefail

export LFS=/mnt/lfs
SOURCES="$LFS/sources"

chmod -v a+wt "$SOURCES"

echo "### Downloading packages..."
if ! wget --input-file=wget-list-sysv \
          --continue \
          --directory-prefix="$SOURCES" \
          --no-verbose \
          --show-progress; then
    echo -e "\n❌ WARNING: One or more downloads failed."
    echo "You may review the messages above to identify the missing files."
    
    read -rp "Do you want to continue with checksum verification anyway? [y/N] " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        echo "→ Continuing despite download issues..."
    else
        echo "⏹️ Aborting."
        exit 1
    fi
fi

echo "### Copying md5sums"
cp -v md5sums "$SOURCES"

echo "### Verifying checksums"
pushd "$SOURCES" > /dev/null
md5sum -c md5sums || echo "⚠️ Some checksums failed or files were missing (as expected if downloads failed)."
popd > /dev/null

chown root:root "$SOURCES"/*

