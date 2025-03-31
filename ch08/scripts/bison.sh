#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting bison"
tar -xf bison-3.8.2.tar.xz
cd bison-3.8.2

echo "### Configuring bison"
./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.8.2

echo "### Building bison"
make

echo "### Running bison test suite"
make check

echo "### Installing bison"
make install

cd ..
rm -rf bison-3.8.2
popd
