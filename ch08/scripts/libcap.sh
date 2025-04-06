#!/bin/bash
set -eu

echo "### Entering /sources"
pushd /sources

echo "### Extracting libcap"
tar -xf libcap-2.73.tar.xz
cd libcap-2.73

echo "### Preventing static lib installation"
sed -i '/install -m.*STA/d' libcap/Makefile

echo "### Building libcap"
make prefix=/usr lib=lib

echo "### Running libcap test suite"
make test

echo "### Installing libcap"
make prefix=/usr lib=lib install

cd ..
rm -rf libcap-2.73
popd
