#!/bin/bash
set -eu

echo "### Entering /sources"
pushd /sources

echo "### Extracting lz4"
tar -xf lz4-1.10.0.tar.gz
cd lz4-1.10.0

echo "### Building lz4"
make BUILD_STATIC=no PREFIX=/usr

echo "### Running lz4 test suite"
make -j1 check

echo "### Installing lz4"
make BUILD_STATIC=no PREFIX=/usr install

cd ..
rm -rf lz4-1.10.0
popd
