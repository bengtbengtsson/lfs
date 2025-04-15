#!/bin/bash
set -eu

# Chapter blfs package installation script
mkdir -pv /scripts/blfs/scripts
mkdir -pv /scripts/blfs/sources

packages=(
  fonts
  wifi
  openssh
  wget
  curl
  git
  lynx
  cmake
  neovim
  sudo
  new_user
)

for pkg in "${packages[@]}"; do
  echo "### Building $pkg..."
  ./scripts/$pkg.sh
  echo "### Finished $pkg"
done

