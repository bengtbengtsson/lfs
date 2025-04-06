#!/bin/bash
set -eu

echo "### Entering /sources"
pushd /sources

echo "### Extracting Kbd"
tar -xf kbd-2.7.1.tar.xz
cd kbd-2.7.1

echo "### Applying backspace patch"
patch -Np1 -i ../kbd-2.7.1-backspace-1.patch

echo "### Removing resizecons program"
sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in

echo "### Configuring Kbd"
./configure --prefix=/usr --disable-vlock

echo "### Building Kbd"
make

echo "### Running tests for Kbd"
make check

echo "### Installing Kbd"
make install

echo "### Installing Kbd documentation"
cp -R -v docs/doc -T /usr/share/doc/kbd-2.7.1

cd ..
rm -rf kbd-2.7.1
popd
