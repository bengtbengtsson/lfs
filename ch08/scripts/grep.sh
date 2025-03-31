#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting grep"
tar -xf grep-3.11.tar.xz
cd grep-3.11

echo "### Removing egrep/fgrep warning"
sed -i "s/echo/#echo/" src/egrep.sh

echo "### Configuring grep"
./configure --prefix=/usr

echo "### Building grep"
make

echo "### Running grep test suite"
make check

echo "### Installing grep"
make install

cd ..
rm -rf grep-3.11
popd
