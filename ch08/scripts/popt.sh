#!/bin/bash
set -e

. /sources/.lfsenv || {
  echo "❌ Could not load LFS environment."
  exit 1
}

if [ "$LFS_PART_SCHEME" = "gpt" ]; then
  echo "### Entering /sources"
  pushd /sources

  tar -xf popt-1.19.tar.gz
  cd popt-1.19

  ./configure --prefix=/usr --disable-static
  make
  make check
  make install
  
  cd ..
  rm -rf popt-1.19
  popd

fi


