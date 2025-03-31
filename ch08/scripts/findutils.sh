#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting Findutils"
tar -xf findutils-4.10.0.tar.xz
cd findutils-4.10.0

echo "### Configuring Findutils"
./configure --prefix=/usr --localstatedir=/var/lib/locate

echo "### Building Findutils"
make

echo "### Running tests for Findutils"
chown -R tester .
su tester -c "PATH=$PATH make check"

echo "### Installing Findutils"
make install

cd ..
rm -rf findutils-4.10.0
popd
