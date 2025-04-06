#!/bin/bash

set -eu

if [ "$(whoami)" != "root" ]; then
  echo "This script must be run as the 'root' user. Aborting."
  exit 1
fi

echo "These are notes, and steps, on how to bring up the LFS system in development mode"
echo "Be careful not to brake things!"
echo "As of now we expect the /dev/sdb being used, with gpt partition scheme"

echo "Mount the drives"
mkdir -pv /mnt/lfs
mount -t ext4 /dev/sdb3 /mnt/lfs
mkdir -pv /mnt/lfs/boot
mount -t vfat /dev/sdb1 /mnt/lfs/boot 

echo "Setting umask to 22"
umask 022

echo "Activating the enviroment variables"
echo "You might confirm this by running 'env'"

. /sources/.lfsenv || {
  echo "❌ Could not load LFS environment."
  exit 1
}

echo "Mounting the virtual file system"
mount -v --bind /dev $LFS/dev
mount -vt devpts devpts -o gid=5,mode=0620 $LFS/dev/pts
mount -vt proc proc $LFS/proc
mount -vt sysfs sysfs $LFS/sys
mount -vt tmpfs tmpfs $LFS/run

echo
echo "✅ All mounts complete. You're now ready to run ./rechroot.sh"
echo "Use 'mount | grep /mnt/lfs' to verify all mount points"

