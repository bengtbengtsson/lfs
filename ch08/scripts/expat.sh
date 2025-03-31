#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting expat"
tar -xf expat-2.6.4.tar.xz
cd expat-2.6.4

echo "### Configuring expat"
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/expat-2.6.4

echo "### Building expat"
make

echo "### Running expat test suite"
make check

echo "### Installing expat"
make install

echo "### Installing expat documentation"
install -v -m644 doc/*.{html,css} /usr/share/doc/expat-2.6.4

cd ..
rm -rf expat-2.6.4
popd
