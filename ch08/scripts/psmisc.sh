#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting psmisc"
tar -xf psmisc-23.7.tar.xz
cd psmisc-23.7

echo "### Configuring psmisc"
./configure --prefix=/usr

echo "### Building psmisc"
make

echo "### Running psmisc test suite"
make check

echo "### Installing psmisc"
make install

cd ..
rm -rf psmisc-23.7
popd
