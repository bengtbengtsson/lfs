#!/bin/bash
# This script is used to build patch
# This script should be run as lfs user

set -e

# Check that LFS and LFS_TGT are set
if [ -z "$LFS" ] || [ -z "$LFS_TGT" ]; then
  echo "Error: One or both required environment variables are not set."
  echo "Make sure both \$LFS and \$LFS_TGT are defined."
  exit 1
fi

cd $LFS/sources

tar -xvf patch-2.7.6.tar.xz 
cd patch-2.7.6

./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)

make -j$(nproc)

make DESTDIR=$LFS install

cd $LFS/sources
rm -rf patch-2.7.6
