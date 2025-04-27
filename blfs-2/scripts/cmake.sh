#!/bin/bash
set -euo pipefail

SOURCES=/scripts/blfs/sources/

echo "Installing icu"
pushd ${SOURCES}
  tar -xvf icu4c-76_1-src.tgz
  cd icu
  
  cd source

  ./configure --prefix=/usr
  make
  make install

  cd ../..
  rm -rf icu
popd

echo "Done installing icu"

echo "Installing libxml2"
pushd ${SOURCES}
  tar -xvf libxml2-2.13.6.tar.xz
  cd libxml2-2.13.6
  
  ./configure --prefix=/usr           \
            --sysconfdir=/etc       \
            --disable-static        \
            --with-history          \
            --with-icu              \
            PYTHON=/usr/bin/python3 \
            --docdir=/usr/share/doc/libxml2-2.13.6 &&
  make
  make install

  rm -vf /usr/lib/libxml2.la &&
  sed '/libs=/s/xml2.*/xml2"/' -i /usr/bin/xml2-config

  cd ..
  rm -rf libxml2-2.13.6
popd

echo "Done installing libxml2"

echo "Installing nghttp2"
pushd ${SOURCES}
  tar -xvf nghttp2-1.64.0.tar.xz
  cd nghttp2-1.64.0
  
  ./configure --prefix=/usr     \
            --disable-static  \
            --enable-lib-only \
            --docdir=/usr/share/doc/nghttp2-1.64.0 &&
  make
  make install

  cd ..
  rm -rf nghttp2-1.64.0
popd

echo "Done installing nghttp2"

echo "Installing libuv"
pushd ${SOURCES}
  tar -xvf libuv-v1.50.0.tar.gz
  cd libuv-v1.50.0
  
  sh autogen.sh                              &&
  ./configure --prefix=/usr --disable-static &&
  make 
  make install

  cd ..
  rm -rf libuv-v1.50.0
popd

echo "Done installing libuv"

echo "Installing libarchive"
pushd ${SOURCES}
  tar -xvf libarchive-3.7.7.tar.xz
  cd libarchive-3.7.7
 
  ./configure --prefix=/usr --disable-static &&
  make
  make install

  ln -sfv bsdunzip /usr/bin/unzip
  
popd

echo "Done installing libarchive"

echo "Installing  cmake"
pushd ${SOURCES}
  tar -xvf cmake-3.31.5.tar.gz
  cd cmake-3.31.5
  
  sed -i '/"lib64"/s/64//' Modules/GNUInstallDirs.cmake &&

  ./bootstrap --prefix=/usr        \
              --system-libs        \
              --mandir=/share/man  \
              --no-system-jsoncpp  \
              --no-system-cppdap   \
              --no-system-librhash \
              --docdir=/share/doc/cmake-3.31.5 &&
  make
  make install

  cd ..
  rm -rf cmake-3.31.5 
popd

echo "Done installing cmake"
