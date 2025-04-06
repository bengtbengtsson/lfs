#!/bin/bash
set -eu

echo "### Entering /sources"
pushd /sources

echo "### Extracting intltool"
tar -xf intltool-0.51.0.tar.gz
cd intltool-0.51.0

echo "### Fixing Perl brace warning"
sed -i 's:\\\${:\\\$\\{:' intltool-update.in

echo "### Configuring intltool"
./configure --prefix=/usr

echo "### Building intltool"
make

echo "### Running intltool test suite"
make check

echo "### Installing intltool"
make install
install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO

cd ..
rm -rf intltool-0.51.0
popd
