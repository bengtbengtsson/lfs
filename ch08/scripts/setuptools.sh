#!/bin/bash
set -eu

echo "### Entering /sources"
pushd /sources

echo "### Extracting setuptools"
tar -xf setuptools-75.8.1.tar.gz
cd setuptools-75.8.1

echo "### Building setuptools wheel"
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

echo "### Installing setuptools"
pip3 install --no-index --find-links dist setuptools

cd ..
rm -rf setuptools-75.8.1
popd
