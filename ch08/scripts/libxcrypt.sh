#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting libxcrypt"
tar -xf libxcrypt-4.4.38.tar.xz
cd libxcrypt-4.4.38

echo "### Configuring libxcrypt"
./configure --prefix=/usr                \
            --enable-hashes=strong,glibc \
            --enable-obsolete-api=no     \
            --disable-static             \
            --disable-failure-tokens

echo "### Building libxcrypt"
make

echo "### Running libxcrypt test suite"
make check

echo "### Installing libxcrypt"
make install

cd ..
rm -rf libxcrypt-4.4.38
popd
