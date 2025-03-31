#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting attr"
tar -xf attr-2.5.2.tar.gz
cd attr-2.5.2

echo "### Configuring attr"
./configure --prefix=/usr     \
            --disable-static  \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/attr-2.5.2

echo "### Building attr"
make

echo "### Running attr test suite (requires ext2/3/4 fs)"
make check

echo "### Installing attr"
make install

cd ..
rm -rf attr-2.5.2
popd
