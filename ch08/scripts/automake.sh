#!/bin/bash
set -eu

echo "### Entering /sources"
pushd /sources

echo "### Extracting automake"
tar -xf automake-1.17.tar.xz
cd automake-1.17

echo "### Configuring automake"
./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.17

echo "### Building automake"
make

echo "### Running automake test suite with adjusted parallelism"
make -j$(($(nproc)>4?$(nproc):4)) check

echo "### Installing automake"
make install

cd ..
rm -rf automake-1.17
popd
