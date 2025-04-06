#!/bin/bash
set -eu

echo "### Entering /sources"
pushd /sources

echo "### Extracting SysVinit"
tar -xf sysvinit-3.14.tar.xz
cd sysvinit-3.14

echo "### Patching SysVinit"
patch -Np1 -i ../sysvinit-3.14-consolidated-1.patch

echo "### Building SysVinit"
make

echo "### Installing SysVinit"
make install

cd ..
rm -rf sysvinit-3.14
popd
