#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting m4"
tar -xf m4-1.4.19.tar.xz
cd m4-1.4.19

echo "### Configuring m4"
./configure --prefix=/usr

echo "### Building m4"
make

echo "### Running m4 test suite"
make check

echo "### Installing m4"
make install

cd ..
rm -rf m4-1.4.19
popd

