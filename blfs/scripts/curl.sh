#!/bin/bash
set -euo pipefail

SOURCES=/scripts/blfs/sources/

# TODO summarize kernel build and driver install
#
echo "Installing libunistring"
pushd ${SOURCES}
  tar -xvf libunistring-1.3.tar.xz
  cd libunistring-1.3

  ./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/libunistring-1.3 &&
  make
  make install

  cd ..
  rm -rf libunistring-1.3
popd
echo "Done installing libunistring"

echo "Installing libidn2"
pushd ${SOURCES}
  tar -xvf libidn2-2.3.7.tar.gz
  cd libidn2-2.3.7

  ./configure --prefix=/usr --disable-static &&

  make
  make install

  cd ..
  rm -rf libidn2-2.3.7
popd
echo "Done installing libidn2"

echo "Installing libpsl"
pushd ${SOURCES}
  tar -xvf libpsl-0.21.5.tar.gz 
  cd libpsl-0.21.5

  mkdir build &&
  cd build &&

  meson setup --prefix=/usr --buildtype=release &&

  ninja

  ninja install

  cd ../..
  rm -rf libpsl-2.21.5
popd
echo "Done installing libpsl"

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

# Certs install as per wget script
echo "Installing certs"
file=/etc/curlrc
line='cacert = "/etc/ssl/certs/ca-certificates.crt"'

if [ -f "$file" ]; then
  grep -qxF "$line" "$file" || echo "$line" >> "$file"
else
  echo "$line" > "$file"
fi

echo "Done installing certs"

echo "Done installing curl"

