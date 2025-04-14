#!/bin/bash
set -euo pipefail

SOURCES=/scripts/blfs/sources/

echo "📦 Installing neovim"
pushd "${SOURCES}"

  # Handle archive presence and naming
  if [[ -f neovim.zip ]]; then
    echo "✅ Found neovim.zip"
  elif [[ -f master.zip ]]; then
    echo "📦 Found master.zip, renaming to neovim.zip"
    mv master.zip neovim.zip
  else
    echo "❌ No neovim.zip or master.zip found. Aborting."
    exit 1
  fi

  # Unpack if not already unpacked
  if [[ ! -d neovim ]]; then
    unzip -q neovim.zip
    # Handle extracted folder name like neovim-master
    extracted_dir=$(unzip -Z -1 neovim.zip | head -n1 | cut -d/ -f1)
    mv "$extracted_dir" neovim
  fi

  cd neovim

  make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=/usr
  make install

  cd ..
  rm -rf neovim

popd
echo "✅ Done installing neovim"

