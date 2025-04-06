#!/bin/bash
set -eu

echo "### Entering /sources"
pushd /sources

echo "### Extracting lfs-bootscripts"
tar -xf lfs-bootscripts-20240825.tar.xz
cd lfs-bootscripts-20240825

echo "### Installing lfs-bootscripts-20240825"
make install

cd ..
rm -rf lfs-bootscripts-20240825
popd

