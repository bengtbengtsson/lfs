#!/bin/bash

set -e

. /sources/.lfsenv || {
  echo "❌ Could not load LFS environment. Is .lfsenv missing?"
  exit 1
}

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

# set up grub
grub-install $LFS_BOOT --target i386-pc

cat > /boot/grub/grub.cfg << "EOF"
# Begin /boot/grub/grub.cfg
set default=0
set timeout=5

insmod part_gpt
insmod ext2
set root=(hd0,1)
set gfxpayload=1024x768x32

menuentry "GNU/Linux, Linux 6.13.4-lfs-12.3" {
        linux   /boot/vmlinuz-6.13.4-lfs-12.3 root=/dev/sda2 ro
}
EOF

echo "LFS has been installed"
echo "Exit the chroot environment, unmount the devices and reboot."
echo "Good luck..."
