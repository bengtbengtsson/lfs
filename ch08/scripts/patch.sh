#!/bin/bash
set -eu

echo "### Entering /sources"
pushd /sources

echo "### Extracting Patch"
tar -xf patch-2.7.6.tar.xz
cd patch-2.7.6

echo "### Configuring Patch"
./configure --prefix=/usr

echo "### Building Patch"
make

echo "### Running tests for Patch"
make check

echo "### Installing Patch"
make install

cd ..
rm -rf patch-2.7.6
popd
