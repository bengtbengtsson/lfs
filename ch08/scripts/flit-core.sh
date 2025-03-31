#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting flit-core"
tar -xf flit-core-3.11.0.tar.gz
cd flit-core-3.11.0

echo "### Building flit-core wheel"
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

echo "### Installing flit-core from local wheel"
pip3 install --no-index --find-links dist flit_core

cd ..
rm -rf flit-core-3.11.0
popd
