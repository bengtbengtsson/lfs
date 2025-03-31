#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting Libpipeline"
tar -xf libpipeline-1.5.8.tar.gz
cd libpipeline-1.5.8

echo "### Configuring Libpipeline"
./configure --prefix=/usr

echo "### Building Libpipeline"
make

echo "### Running tests for Libpipeline"
make check

echo "### Installing Libpipeline"
make install

cd ..
rm -rf libpipeline-1.5.8
popd
