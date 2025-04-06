#!/bin/bash
set -eu

echo "### Entering /sources"
pushd /sources

echo "### Extracting pkgconf"
tar -xf pkgconf-2.3.0.tar.xz
cd pkgconf-2.3.0

echo "### Configuring pkgconf"
./configure --prefix=/usr              \
            --disable-static           \
            --docdir=/usr/share/doc/pkgconf-2.3.0

echo "### Building pkgconf"
make

echo "### Installing pkgconf"
make install

echo "### Creating pkg-config compatibility symlinks"
ln -sv pkgconf   /usr/bin/pkg-config
ln -sv pkgconf.1 /usr/share/man/man1/pkg-config.1

cd ..
rm -rf pkgconf-2.3.0
popd
