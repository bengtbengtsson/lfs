#!/bin/bash
set -eu

echo "### Entering /sources"
pushd /sources

echo "### Extracting gettext"
tar -xf gettext-0.24.tar.xz
cd gettext-0.24

echo "### Configuring gettext"
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-0.24

echo "### Building gettext"
make

echo "### Running gettext test suite"
make check

echo "### Installing gettext"
make install

echo "### Fixing permissions on preloadable_libintl"
chmod -v 0755 /usr/lib/preloadable_libintl.so

cd ..
rm -rf gettext-0.24
popd
