#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting acl"
tar -xf acl-2.3.2.tar.xz
cd acl-2.3.2

echo "### Configuring acl"
./configure --prefix=/usr         \
            --disable-static      \
            --docdir=/usr/share/doc/acl-2.3.2

echo "### Building acl"
make

echo "### Running acl test suite (ignore known cp.test failure)"
make check

echo "### Installing acl"
make install

cd ..
rm -rf acl-2.3.2
popd
