#!/bin/bash
set -eu

# Chapter blfs package installation script
mkdir -pv /scripts/blfs/scripts

packages=(
  fonts
)

for pkg in "${packages[@]}"; do
  echo "### Building $pkg..."
  ./scripts/$pkg.sh
  echo "### Finished $pkg"
done

