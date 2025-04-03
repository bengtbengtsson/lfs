#!/bin/bash
set -e

if [ "$(whoami)" != "lfs" ]; then
  echo "This script must be run as the 'lfs' user. Aborting."
  exit 1
fi

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

