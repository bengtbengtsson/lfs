#!/bin/bash
set -eu

echo "### Entering /sources"
pushd /sources

echo "### Extracting Procps-ng"
tar -xf procps-ng-4.0.5.tar.xz
cd procps-ng-4.0.5

echo "### Configuring Procps-ng"
./configure --prefix=/usr                           \
            --docdir=/usr/share/doc/procps-ng-4.0.5 \
            --disable-static                        \
            --disable-kill                          \
            --enable-watch8bit

echo "### Building Procps-ng"
make

echo "### Preparing for tests"
chown -R tester .

echo "### Running Procps-ng test suite"
su tester -c "PATH=$PATH make check"

echo "### Installing Procps-ng"
make install

cd ..
rm -rf procps-ng-4.0.5
popd
