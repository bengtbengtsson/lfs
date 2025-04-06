#!/bin/bash
set -eu

echo "### Entering /sources"
pushd /sources

echo "### Extracting Man-DB"
tar -xf man-db-2.13.0.tar.xz
cd man-db-2.13.0

echo "### Configuring Man-DB"
./configure --prefix=/usr                         \
            --docdir=/usr/share/doc/man-db-2.13.0 \
            --sysconfdir=/etc                     \
            --disable-setuid                      \
            --enable-cache-owner=bin              \
            --with-browser=/usr/bin/lynx          \
            --with-vgrind=/usr/bin/vgrind         \
            --with-grap=/usr/bin/grap             \
            --with-systemdtmpfilesdir=            \
            --with-systemdsystemunitdir=

echo "### Building Man-DB"
make

echo "### Running Man-DB test suite"
make check

echo "### Installing Man-DB"
make install

cd ..
rm -rf man-db-2.13.0
popd
