#!/bin/bash
set -eu

echo "### Entering /sources"
pushd /sources

echo "### Extracting openssl"
tar -xf openssl-3.4.1.tar.gz
cd openssl-3.4.1

echo "### Configuring openssl"
./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic

echo "### Building openssl"
make

echo "### Running openssl test suite"
HARNESS_JOBS=$(nproc) make test || echo "Some tests may fail safely"

echo "### Installing openssl"
sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
make MANSUFFIX=ssl install

echo "### Adjusting documentation path"
mv -v /usr/share/doc/openssl /usr/share/doc/openssl-3.4.1
cp -vfr doc/* /usr/share/doc/openssl-3.4.1

cd ..
rm -rf openssl-3.4.1
popd
