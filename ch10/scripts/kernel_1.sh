#!/bin/bash

set -eu

cd /sources
tar -xvf linux-6.13.4.tar.xz
cd linux-6.13.4

make mrproper
cp -iv ../../xtra/config-lfs-12.3 .config

echo "A '.config' file taylored for LFS 12.3 has been copied to the linux directory."
echo "If needed, continue with manual config"
echo "Start manual config by executing 'make menuconfig' inside the linux directory"
echo "When config is ready, then execute ./kernel_2.sh.
