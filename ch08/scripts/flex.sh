#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting flex"
tar -xf flex-2.6.4.tar.gz
cd flex-2.6.4

echo "### Configuring flex"
./configure --prefix=/usr \
            --docdir=/usr/share/doc/flex-2.6.4 \
            --disable-static

echo "### Building flex"
make

echo "### Running flex test suite"
make check

echo "### Installing flex"
make install

echo "### Creating legacy symlinks for lex compatibility"
ln -sv flex   /usr/bin/lex
ln -sv flex.1 /usr/share/man/man1/lex.1

cd ..
rm -rf flex-2.6.4
popd
