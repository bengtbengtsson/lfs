#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting MarkupSafe"
tar -xf MarkupSafe-3.0.2.tar.gz
cd MarkupSafe-3.0.2

echo "### Building MarkupSafe wheel"
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

echo "### Installing MarkupSafe"
pip3 install --no-index --find-links dist MarkupSafe

cd ..
rm -rf MarkupSafe-3.0.2
popd
