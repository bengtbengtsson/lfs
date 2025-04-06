#!/bin/bash
set -eu

echo "### Entering /sources"
pushd /sources

echo "### Extracting zlib"
tar -xf zlib-1.3.1.tar.gz
cd zlib-1.3.1

echo "### Configuring zlib"
./configure --prefix=/usr

echo "### Building zlib"
make

echo "### Running zlib test suite"
make check

echo "### Installing zlib"
make install

echo "### Removing static lib"
rm -fv /usr/lib/libz.a

cd ..
rm -rf zlib-1.3.1
popd
