#!/bin/bash
set -euo pipefail

SOURCES=/scripts/blfs/sources/

# TODO summarize kernel build and driver install
#
echo "Installing curl"
pushd ${SOURCES}
  tar -xvf curl-8.12.1.tar.xz
  cd curl-8.12.1

  ./configure --prefix=/usr                           \
            --disable-static                        \
            --with-openssl                          \
            --with-ca-path=/etc/ssl/certs &&
  make
  
  make install &&

  rm -rf docs/examples/.deps &&

  find docs \( -name Makefile\* -o  \
              -name \*.1       -o  \
              -name \*.3       -o  \
              -name CMakeLists.txt \) -delete &&

  cp -v -R docs -T /usr/share/doc/curl-8.12.1

  cd ..
  rm -rf curl-8.12.1
popd
echo "Done installing curl"

