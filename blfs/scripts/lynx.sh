#!/bin/bash
set -euo pipefail

SOURCES=/scripts/blfs/sources/

# TODO summarize kernel build and driver install
#
echo "Installing lynx"
pushd ${SOURCES}
  tar -xvf lynx2.9.2.tar.bz2 
  cd lynx2.9.2
  
  ./configure --prefix=/usr           \
          --sysconfdir=/etc/lynx  \
          --with-zlib             \
          --with-bzlib            \
          --with-ssl              \
          --with-screen=ncursesw  \
          --enable-locale-charset \
          --datadir=/usr/share/doc/lynx-2.9.2 &&
  make
  make install-full
  chgrp -v -R root /usr/share/doc/lynx-2.9.2/lynx_doc
  cd ..
  rm -rf lynx2.9.2
popd


echo "Done installing lynx"

