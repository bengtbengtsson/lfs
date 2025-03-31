#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting bzip2"
tar -xf bzip2-1.0.8.tar.gz
cd bzip2-1.0.8

echo "### Patching bzip2 to install docs"
patch -Np1 -i ../bzip2-1.0.8-install_docs-1.patch

echo "### Fixing symlink and man page paths"
sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile

echo "### Building shared library"
make -f Makefile-libbz2_so
make clean

echo "### Compiling bzip2"
make

echo "### Installing bzip2"
make PREFIX=/usr install

echo "### Installing shared library"
cp -av libbz2.so.* /usr/lib
ln -sv libbz2.so.1.0.8 /usr/lib/libbz2.so

echo "### Installing shared binary and fixing symlinks"
cp -v bzip2-shared /usr/bin/bzip2
for i in /usr/bin/{bzcat,bunzip2}; do
  ln -sfv bzip2 $i
done

echo "### Removing static library"
rm -fv /usr/lib/libbz2.a

cd ..
rm -rf bzip2-1.0.8
popd

