#!/bin/bash
set -eu

echo "### Entering /sources"
pushd /sources

echo "### Extracting bc"
tar -xf bc-7.0.3.tar.xz
cd bc-7.0.3

echo "### Configuring bc"
CC=gcc ./configure --prefix=/usr -G -O3 -r

echo "### Building bc"
make

echo "### Running bc test suite"
make test

echo "### Installing bc"
make install

cd ..
rm -rf bc-7.0.3
popd
