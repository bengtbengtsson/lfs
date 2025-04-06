#!/bin/bash
set -eu

echo "### Entering /sources"
pushd /sources

echo "### Extracting Groff"
tar -xf groff-1.23.0.tar.gz
cd groff-1.23.0

echo "### Configuring Groff with A4 paper size"
PAGE=A4 ./configure --prefix=/usr

echo "### Building Groff"
make

echo "### Running tests for Groff"
make check

echo "### Installing Groff"
make install

cd ..
rm -rf groff-1.23.0
popd
