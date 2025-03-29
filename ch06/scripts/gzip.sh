#!/bin/bash
# This script is used to build gzip
# This script should be run as lfs user

set -e

# Check that LFS and LFS_TGT are set
if [ -z "$LFS" ] || [ -z "$LFS_TGT" ]; then
  echo "Error: One or both required environment variables are not set."
  echo "Make sure both \$LFS and \$LFS_TGT are defined."
  exit 1
fi

cd $LFS/sources

tar -xvf gzip-1.13.tar.xz 
cd gzip-1.13

./configure --prefix=/usr --host=$LFS_TGT

make -j$(nproc)

make DESTDIR=$LFS install

cd $LFS/sources
rm -rf gzip-1.13



