#!/bin/bash
set -e

. /sources/.lfsenv || {
  echo "❌ Could not load LFS environment."
  exit 1
}

if [ "$LFS_PART_SCHEME" = "gpt" ]; then
  echo "### Entering /sources"
  pushd /sources

  tar -xf efibootmgr-18.tar.gz
  cd efibootmgr-18

  make EFIDIR=LFS EFI_LOADER=grubx64.efi
  make install EFIDIR=LFS

  cd ..
  rm -rf efibootmgr-18
  popd

fi



