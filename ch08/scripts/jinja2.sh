#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting Jinja2"
tar -xf Jinja2-3.1.5.tar.gz
cd Jinja2-3.1.5

echo "### Building Jinja2 wheel"
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

echo "### Installing Jinja2"
pip3 install --no-index --find-links dist Jinja2

cd ..
rm -rf Jinja2-3.1.5
popd
