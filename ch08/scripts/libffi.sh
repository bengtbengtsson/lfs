#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting libffi"
tar -xf libffi-3.4.7.tar.gz
cd libffi-3.4.7

echo "### Configuring libffi"
./configure --prefix=/usr          \
            --disable-static       \
            --with-gcc-arch=native

echo "### Building libffi"
make

echo "### Running libffi test suite"
make check

echo "### Installing libffi"
make install

cd ..
rm -rf libffi-3.4.7
popd
