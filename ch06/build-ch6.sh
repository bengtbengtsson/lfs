#!/bin/bash
set -e

# Define your build list
packages=(
  "m4"
  "ncurses"
  "bash"
  "coreutils"
  "diffutils"
  "file"
  "findutils"
  "gawk"
  "grep"
  "gzip"
  "make"
  "patch"
  "sed"
  "tar"
  "xz"
  "binutils-pass2"
  "gcc-pass2"
)

for pkg in "${packages[@]}"; do
  echo "### Building $pkg..."
  ./scripts/$pkg.sh
  echo "### Finished $pkg"
done

