#!/bin/bash
set -eu

echo "### Entering /sources"
pushd /sources

echo "### Extracting Make"
tar -xf make-4.4.1.tar.gz
cd make-4.4.1

echo "### Configuring Make"
./configure --prefix=/usr

echo "### Building Make"
make

echo "### Running tests for Make"
chown -R tester .
su tester -c "PATH=$PATH make check"

echo "### Installing Make"
make install

cd ..
rm -rf make-4.4.1
popd
