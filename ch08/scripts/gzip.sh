#!/bin/bash
set -eu

echo "### Entering /sources"
pushd /sources

echo "### Extracting Gzip"
tar -xf gzip-1.13.tar.xz
cd gzip-1.13

echo "### Configuring Gzip"
./configure --prefix=/usr

echo "### Building Gzip"
make

echo "### Testing Gzip"
make check

echo "### Installing Gzip"
make install

cd ..
rm -rf gzip-1.13
popd
