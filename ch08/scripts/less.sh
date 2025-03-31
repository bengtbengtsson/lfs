#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting less"
tar -xf less-668.tar.gz
cd less-668

echo "### Configuring less"
./configure --prefix=/usr --sysconfdir=/etc

echo "### Building less"
make

echo "### Running less test suite"
make check

echo "### Installing less"
make install

cd ..
rm -rf less-668
popd
