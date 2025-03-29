#!/bin/bash
# This script is used to build bash
# This script should be run as lfs user

set -e

# Check that LFS and LFS_TGT are set
if [ -z "$LFS" ] || [ -z "$LFS_TGT" ]; then
  echo "Error: One or both required environment variables are not set."
  echo "Make sure both \$LFS and \$LFS_TGT are defined."
  exit 1
fi

cd $LFS/sources

tar -xvf bash-5.2.37.tar.xz 
cd bash-5.2.37

./configure --prefix=/usr                      \
            --build=$(sh support/config.guess) \
            --host=$LFS_TGT                    \
            --without-bash-malloc

make -j$(nproc)
make DESTDIR=$LFS install

ln -sv bash $LFS/bin/sh

cd $LFS/sources
rm -rf bash-5.2.37


