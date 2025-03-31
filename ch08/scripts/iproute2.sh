#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting IPRoute2"
tar -xf iproute2-6.13.0.tar.xz
cd iproute2-6.13.0

echo "### Removing arpd references"
sed -i /ARPD/d Makefile
rm -fv man/man8/arpd.8

echo "### Building IPRoute2"
make NETNS_RUN_DIR=/run/netns

echo "### Installing IPRoute2"
make SBINDIR=/usr/sbin install

echo "### Installing IPRoute2 docs"
install -vDm644 COPYING README* -t /usr/share/doc/iproute2-6.13.0

cd ..
rm -rf iproute2-6.13.0
popd
