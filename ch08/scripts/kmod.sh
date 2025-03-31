#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting kmod"
tar -xf kmod-34.tar.xz
cd kmod-34

echo "### Creating build directory and configuring with meson"
mkdir -p build
cd build
meson setup --prefix=/usr \
            --sbindir=/usr/sbin \
            --buildtype=release \
            -D manpages=false ..

echo "### Building kmod"
ninja

echo "### Installing kmod"
ninja install

cd ../..
rm -rf kmod-34
popd
