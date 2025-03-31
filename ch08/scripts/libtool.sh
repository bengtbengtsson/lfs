#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting libtool"
tar -xf libtool-2.5.4.tar.xz
cd libtool-2.5.4

echo "### Configuring libtool"
./configure --prefix=/usr

echo "### Building libtool"
make

echo "### Running libtool test suite"
make check

echo "### Installing libtool"
make install

echo "### Removing static library"
rm -fv /usr/lib/libltdl.a

cd ..
rm -rf libtool-2.5.4
popd
