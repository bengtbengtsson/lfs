#!/bin/bash
# This script is used to build file
# This script should be run as lfs user

set -e

# Check that LFS and LFS_TGT are set
if [ -z "$LFS" ] || [ -z "$LFS_TGT" ]; then
  echo "Error: One or both required environment variables are not set."
  echo "Make sure both \$LFS and \$LFS_TGT are defined."
  exit 1
fi

cd $LFS/sources

tar -xvf file-5.46.tar.gz 
cd file-5.46

mkdir build
pushd build
  ../configure --disable-bzlib      \
               --disable-libseccomp \
               --disable-xzlib      \
               --disable-zlib
  make
popd

./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess)

make -j$(nproc) FILE_COMPILE=$(pwd)/build/src/file

make DESTDIR=$LFS install

rm -v $LFS/usr/lib/libmagic.la

cd $LFS/sources
rm -rf file-5.46
