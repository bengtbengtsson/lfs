#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting iana-etc"
tar -xf iana-etc-20250123.tar.gz
cd iana-etc-20250123

echo "### Installing iana-etc (copying files)"
cp services protocols /etc

cd ..
rm -rf iana-etc-20250123

popd
