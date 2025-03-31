#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting sed"
tar -xf sed-4.9.tar.xz
cd sed-4.9

echo "### Configuring sed"
./configure --prefix=/usr

echo "### Building sed and HTML docs"
make
make html

echo "### Running sed test suite"
chown -R tester .
su tester -c "PATH=$PATH make check"

echo "### Installing sed"
make install

echo "### Installing sed documentation"
install -d -m755           /usr/share/doc/sed-4.9
install -m644 doc/sed.html /usr/share/doc/sed-4.9

cd ..
rm -rf sed-4.9
popd
