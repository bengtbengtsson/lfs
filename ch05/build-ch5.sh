#!/bin/bash
set -e

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

