#!/bin/bash

set -eu

cd /sources
tar -xvf linux-6.13.4.tar.xz
cd linux-6.13.4

make mrproper
make defconfig

echo "A default '.config' file has been generated."
echo "Continue with manual config and then execute ./kernel_2.sh."
echo "Start manual config by executing 'make menuconfig' inside the linux directory"
