#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting Check"
tar -xf check-0.15.2.tar.gz
cd check-0.15.2

echo "### Configuring Check"
./configure --prefix=/usr --disable-static

echo "### Building Check"
make

echo "### Running tests for Check"
make check

echo "### Installing Check"
make docdir=/usr/share/doc/check-0.15.2 install

cd ..
rm -rf check-0.15.2
popd
