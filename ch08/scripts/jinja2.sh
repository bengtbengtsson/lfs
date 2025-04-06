#!/bin/bash
set -eu

echo "### Entering /sources"
pushd /sources

echo "### Extracting Jinja2"
tar -xf jinja2-3.1.5.tar.gz
cd jinja2-3.1.5

echo "### Building Jinja2 wheel"
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

echo "### Installing Jinja2"
pip3 install --no-index --find-links dist Jinja2

cd ..
rm -rf jinja2-3.1.5
popd
