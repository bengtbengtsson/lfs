#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting ncurses"
tar -xf ncurses-6.5.tar.gz
cd ncurses-6.5

echo "### Configuring ncurses"
./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --with-cxx-shared       \
            --enable-pc-files       \
            --with-pkg-config-libdir=/usr/lib/pkgconfig

echo "### Building ncurses"
make

echo "### Installing with DESTDIR to avoid shell crash"
make DESTDIR=$PWD/dest install
install -vm755 dest/usr/lib/libncursesw.so.6.5 /usr/lib
rm -v dest/usr/lib/libncursesw.so.6.5

echo "### Patching curses.h for wide-character ABI"
sed -e 's/^#if.*XOPEN.*$/#if 1/' -i dest/usr/include/curses.h

echo "### Copying all from DESTDIR"
cp -av dest/* /

echo "### Creating compatibility symlinks"
for lib in ncurses form panel menu ; do
    ln -sfv lib${lib}w.so /usr/lib/lib${lib}.so
    ln -sfv ${lib}w.pc    /usr/lib/pkgconfig/${lib}.pc
done

ln -sfv libncursesw.so /usr/lib/libcurses.so

echo "### Installing optional documentation"
cp -v -R doc -T /usr/share/doc/ncurses-6.5

cd ..
rm -rf ncurses-6.5
popd
