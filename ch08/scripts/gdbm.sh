#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting gdbm"
tar -xf gdbm-1.24.tar.gz
cd gdbm-1.24

echo "### Configuring gdbm"
./configure --prefix=/usr    \
            --disable-static \
            --enable-libgdbm-compat

echo "### Building gdbm"
make

echo "### Running gdbm test suite"
make check

echo "### Installing gdbm"
make install

cd ..
rm -rf gdbm-1.24
popd
