#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting xz"
tar -xf xz-5.6.4.tar.xz
cd xz-5.6.4

echo "### Configuring xz"
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/xz-5.6.4

echo "### Building xz"
make

echo "### Running xz test suite"
make check

echo "### Installing xz"
make install

cd ..
rm -rf xz-5.6.4
popd
