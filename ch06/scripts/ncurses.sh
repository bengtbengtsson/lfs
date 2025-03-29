#!/bin/bash
# This script is used to build ncurses
# This script should be run as lfs user

set -e

# Check that LFS and LFS_TGT are set
if [ -z "$LFS" ] || [ -z "$LFS_TGT" ]; then
  echo "Error: One or both required environment variables are not set."
  echo "Make sure both \$LFS and \$LFS_TGT are defined."
  exit 1
fi

cd $LFS/sources

tar -xvf ncurses-6.5.tar.xz 
cd ncurses-6.5 

mkdir build
pushd build
  ../configure AWK=gawk
  make -C include
  make -C progs tic
popd

./configure --prefix=/usr                \
            --host=$LFS_TGT              \
            --build=$(./config.guess)    \
            --mandir=/usr/share/man      \
            --with-manpage-format=normal \
            --with-shared                \
            --without-normal             \
            --with-cxx-shared            \
            --without-debug              \
            --without-ada                \
            --disable-stripping          \
            AWK=gawk

make -j$(nproc)
make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install

ln -sv libncursesw.so $LFS/usr/lib/libncurses.so
sed -e 's/^#if.*XOPEN.*$/#if 1/' \
    -i $LFS/usr/include/curses.h

cd $LFS/sources
rm -rf ncurses-6.5


