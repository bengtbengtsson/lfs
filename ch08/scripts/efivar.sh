#!/bin/bash
set -e

. /sources/.lfsenv || {
  echo "❌ Could not load LFS environment."
  exit 1
}

if [ "$LFS_PART_SCHEME" = "gpt" ]; then
  echo "### Entering /sources"
  pushd /sources

  tar -xf efivar-39.tar.gz
  cd efivar-39

  make ENABLE_DOCS=0
  make install ENABLE_DOCS=0 LIBDIR=/usr/lib
  install -vm644 docs/efivar.1 /usr/share/man/man1 &&
  install -vm644 docs/*.3      /usr/share/man/man3

  cd ..
  rm -rf efivar-39
  popd

fi

