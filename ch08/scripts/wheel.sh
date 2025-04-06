#!/bin/bash
set -eu

echo "### Entering /sources"
pushd /sources

echo "### Extracting wheel"
tar -xf wheel-0.45.1.tar.gz
cd wheel-0.45.1

echo "### Building wheel package"
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

echo "### Installing wheel package"
pip3 install --no-index --find-links dist wheel

cd ..
rm -rf wheel-0.45.1
popd
