#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting Tar"
tar -xf tar-1.35.tar.xz
cd tar-1.35

echo "### Configuring Tar"
FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr

echo "### Building Tar"
make

echo "### Running tests for Tar"
make check

echo "### Installing Tar"
make install
make -C doc install-html docdir=/usr/share/doc/tar-1.35

cd ..
rm -rf tar-1.35
popd
