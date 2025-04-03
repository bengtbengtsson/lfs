#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting Texinfo"
tar -xf texinfo-7.2.tar.xz
cd texinfo-7.2

echo "### Configuring Texinfo"
./configure --prefix=/usr

echo "### Building Texinfo"
make

echo "### Running tests for Texinfo"
make check

echo "### Installing Texinfo"
make install

echo "### Optionally installing TeX components"
make TEXMF=/usr/share/texmf install-tex

cd ..
rm -rf texinfo-7.2
popd
