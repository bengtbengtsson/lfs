#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting gperf"
tar -xf gperf-3.1.tar.gz
cd gperf-3.1

echo "### Configuring gperf"
./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.1

echo "### Building gperf"
make

echo "### Running gperf test suite (single job)"
make -j1 check

echo "### Installing gperf"
make install

cd ..
rm -rf gperf-3.1
popd
