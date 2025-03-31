#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting elfutils"
tar -xf elfutils-0.192.tar.bz2
cd elfutils-0.192

echo "### Configuring libelf"
./configure --prefix=/usr                \
            --disable-debuginfod         \
            --enable-libdebuginfod=dummy

echo "### Building libelf (from elfutils)"
make

echo "### Running libelf test suite"
make check

echo "### Installing only libelf"
make -C libelf install
install -vm644 config/libelf.pc /usr/lib/pkgconfig
rm /usr/lib/libelf.a

cd ..
rm -rf elfutils-0.192
popd
