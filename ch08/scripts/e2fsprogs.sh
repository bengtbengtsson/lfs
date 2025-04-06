#!/bin/bash
set -eu

echo "### Entering /sources"
pushd /sources

echo "### Extracting E2fsprogs"
tar -xf e2fsprogs-1.47.2.tar.gz
cd e2fsprogs-1.47.2

echo "### Creating build directory"
mkdir -v build
cd build

echo "### Configuring E2fsprogs"
../configure --prefix=/usr           \
             --sysconfdir=/etc       \
             --enable-elf-shlibs     \
             --disable-libblkid      \
             --disable-libuuid       \
             --disable-uuidd         \
             --disable-fsck

echo "### Building E2fsprogs"
make

echo "### Running E2fsprogs test suite"
make check

echo "### Installing E2fsprogs"
make install

echo "### Removing static libraries"
rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a

echo "### Installing and updating info pages"
gunzip -v /usr/share/info/libext2fs.info.gz
install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info

echo "### Creating and installing additional documentation"
makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo
install -v -m644 doc/com_err.info /usr/share/info
install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info

cd ../..
rm -rf e2fsprogs-1.47.2
popd
