#!/bin/bash
set -eu

echo "### Entering /sources"
pushd /sources

echo "### Extracting zstd"
tar -xf zstd-1.5.7.tar.gz
cd zstd-1.5.7

echo "### Building zstd"
make prefix=/usr

echo "### Running zstd test suite (ignore 'failed' lines, only 'FAIL' matters)"
make check

echo "### Installing zstd"
make prefix=/usr install

echo "### Removing static library"
rm -v /usr/lib/libzstd.a

cd ..
rm -rf zstd-1.5.7
popd
