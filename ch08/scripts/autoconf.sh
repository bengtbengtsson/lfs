#!/bin/bash
set -eu

echo "### Entering /sources"
pushd /sources

echo "### Extracting autoconf"
tar -xf autoconf-2.72.tar.xz
cd autoconf-2.72

echo "### Configuring autoconf"
./configure --prefix=/usr

echo "### Building autoconf"
make

echo "### Running autoconf test suite"
make check

echo "### Installing autoconf"
make install

cd ..
rm -rf autoconf-2.72
popd
