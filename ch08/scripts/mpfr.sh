#!/bin/bash
set -eu

echo "### Entering /sources"
pushd /sources

echo "### Extracting mpfr"
tar -xf mpfr-4.2.1.tar.xz
cd mpfr-4.2.1

echo "### Configuring mpfr"
./configure --prefix=/usr        \
            --disable-static     \
            --enable-thread-safe \
            --docdir=/usr/share/doc/mpfr-4.2.1

echo "### Building mpfr and docs"
make
make html

echo "### Running mpfr test suite (critical)"
make check

echo "### Installing mpfr"
make install
make install-html

cd ..
rm -rf mpfr-4.2.1
popd
