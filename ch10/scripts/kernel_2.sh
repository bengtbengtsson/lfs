#!/bin/bash
set -eu

# Optionally load environment with LFS_PARTITION_SCHEME
. /sources/.lfsenv

if [[ "${LFS_PARTITION_SCHEME}" == "gpt" ]]; then
  if ! mount | grep -q 'on /boot type vfat'; then
    echo "❌ GPT/UEFI mode detected, but /boot is not mounted as vfat"
    echo "   Please ensure /boot is mounted to your EFI system partition"
    exit 1
  fi
fi

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

echo "✅ Linux kernel has been built and installed."
echo "👉 Now run ./install-grub.sh"

