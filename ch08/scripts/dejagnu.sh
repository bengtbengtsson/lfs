#!/bin/bash
set -eu

echo "### Entering /sources"
pushd /sources

echo "### Extracting dejagnu"
tar -xf dejagnu-1.6.3.tar.gz
cd dejagnu-1.6.3

echo "### Creating build dir"
mkdir -v build
cd build

echo "### Configuring dejagnu"
../configure --prefix=/usr

echo "### Building dejagnu docs"
makeinfo --html --no-split -o doc/dejagnu.html ../doc/dejagnu.texi
makeinfo --plaintext       -o doc/dejagnu.txt  ../doc/dejagnu.texi

echo "### Running dejagnu test suite"
make check

echo "### Installing dejagnu"
make install

echo "### Installing dejagnu docs"
install -v -dm755  /usr/share/doc/dejagnu-1.6.3
install -v -m644   doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.3

cd /sources
rm -rf dejagnu-1.6.3
popd
