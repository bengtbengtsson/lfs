#!/bin/bash
set -e

# Chapter 10 package installation script

packages=(
  fstab
  kernel_1
)

for pkg in "${packages[@]}"; do
  echo "### Building $pkg..."
  ./scripts/$pkg.sh
  echo "### Finished $pkg"
done
