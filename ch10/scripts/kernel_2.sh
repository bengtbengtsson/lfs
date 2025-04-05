#!/bin/bash

set -e

pushd /sources
cd linux-6.13.4

make
make modules_install

cp -iv arch/x86/boot/bzImage /boot/vmlinuz-6.13.4-lfs-12.3
cp -iv System.map /boot/System.map-6.13.4
cp -iv .config /boot/config-6.13.4
cp -r Documentation -T /usr/share/doc/linux-6.13.4

cd ..
rm -rf linux-6.13.4
popd


echo "Linux kernel has been built and installed."
echo "Now run ./install-grub.sh"
