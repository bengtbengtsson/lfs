#!/bin/bash
set -eu

echo "### Entering /sources"
pushd /sources

echo "### Extracting expect"
tar -xf expect5.45.4.tar.gz
cd expect5.45.4

echo "### Patching expect for gcc 14 compatibility"
patch -Np1 -i ../expect-5.45.4-gcc14-1.patch

echo "### Configuring expect"
./configure --prefix=/usr           \
            --with-tcl=/usr/lib     \
            --enable-shared         \
            --disable-rpath         \
            --mandir=/usr/share/man \
            --with-tclinclude=/usr/include

echo "### Building expect"
make

echo "### Running expect test suite"
make test

echo "### Installing expect"
make install

echo "### Creating symlink for libexpect"
ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib

cd ..
rm -rf expect5.45.4
popd
