#!/bin/bash
set -eu

echo "### Entering /sources"
pushd /sources

echo "### Extracting binutils"
tar -xf binutils-2.44.tar.xz
cd binutils-2.44

echo "### Creating build directory"
mkdir -v build
cd build

echo "### Configuring binutils"
../configure --prefix=/usr       \
             --sysconfdir=/etc   \
             --enable-ld=default \
             --enable-plugins    \
             --enable-shared     \
             --disable-werror    \
             --enable-64-bit-bfd \
             --enable-new-dtags  \
             --with-system-zlib  \
             --enable-default-hash-style=gnu

echo "### Building binutils"
make tooldir=/usr

echo "### Running binutils test suite (critical)"
make -k check

echo "### Installing binutils"
make tooldir=/usr install

echo "### Removing unnecessary static libraries and docs"
rm -rfv /usr/lib/lib{bfd,ctf,ctf-nobfd,gprofng,opcodes,sframe}.a \
        /usr/share/doc/gprofng/

cd /sources
rm -rf binutils-2.44
popd
