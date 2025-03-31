#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting man-pages"
tar -xf man-pages-6.12.tar.xz
cd man-pages-6.12

echo "### Removing crypt man pages (handled by libxcrypt later)"
rm -v man3/crypt*

echo "### Installing man-pages"
make -R GIT=false prefix=/usr install

cd ..
rm -rf man-pages-6.12

popd
