#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting Diffutils"
tar -xf diffutils-3.11.tar.xz
cd diffutils-3.11

echo "### Configuring Diffutils"
./configure --prefix=/usr

echo "### Building Diffutils"
make

echo "### Running tests for Diffutils"
make check

echo "### Installing Diffutils"
make install

cd ..
rm -rf diffutils-3.11
popd
