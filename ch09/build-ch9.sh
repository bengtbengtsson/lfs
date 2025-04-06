#!/bin/bash
set -eu

# Chapter 9 package installation script

packages=(
  lfs-bootscripts
  device_management
  systemv_bootscript
)

for pkg in "${packages[@]}"; do
  echo "### Building $pkg..."
  ./scripts/$pkg.sh
  echo "### Finished $pkg"
done
