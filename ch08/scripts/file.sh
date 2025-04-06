#!/bin/bash
set -eu

echo "### Entering /sources"
pushd /sources

echo "### Extracting file"
tar -xf file-5.46.tar.gz
cd file-5.46

echo "### Configuring file"
./configure --prefix=/usr

echo "### Building file"
make

echo "### Running file test suite"
make check

echo "### Installing file"
make install

cd ..
rm -rf file-5.46
popd
