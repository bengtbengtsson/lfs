#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting gmp"
tar -xf gmp-6.3.0.tar.xz
cd gmp-6.3.0

echo "### Configuring gmp"
./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
            --docdir=/usr/share/doc/gmp-6.3.0

echo "### Building gmp and docs"
make
make html

echo "### Running gmp test suite (critical)"
make check 2>&1 | tee gmp-check-log

echo "### Verifying test count (should be >=199)"
awk '/# PASS:/{total+=$3} ; END{print "Total PASS:", total}' gmp-check-log

echo "### Installing gmp"
make install
make install-html

cd ..
rm -rf gmp-6.3.0
popd
