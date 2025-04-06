#!/bin/bash
set -eu

echo "### Entering /sources"
pushd /sources

echo "### Extracting mpc"
tar -xf mpc-1.3.1.tar.gz
cd mpc-1.3.1

echo "### Configuring mpc"
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpc-1.3.1

echo "### Building mpc and docs"
make
make html

echo "### Running mpc test suite"
make check

echo "### Installing mpc"
make install
make install-html

cd ..
rm -rf mpc-1.3.1
popd
