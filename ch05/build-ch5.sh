#!/bin/bash
set -e

if [ "$USER" != "lfs" ]; then
  echo "This script must be run as the 'lfs' user. Aborting."
  exit 1
fi

# Define your build list
packages=(
  "binutils-pass1"
  "gcc-pass1"
  "linux-headers"
  "glibc"
  "libstdcxx"
)

for pkg in "${packages[@]}"; do
  echo "### Building $pkg..."
  ./scripts/$pkg.sh
  echo "### Finished $pkg"
done

