#!/bin/bash

set -eu

. /sources/.lfsenv || {
  echo "❌ Could not load LFS environment. Is .lfsenv missing?"
  exit 1
}

cat > /etc/fstab <<EOF
# Begin /etc/fstab

# file system  mount-point    type     options             dump  fsck
#                                                                order

UUID=${BOOT_UUID}    /boot/efi      vfat     defaults            0     1
UUID=${ROOT_UUID}    /              ext4     defaults            1     1
UUID=${SWAP_UUID}    swap           swap     pri=1               0     0
proc           /proc          proc     nosuid,noexec,nodev 0     0
sysfs          /sys           sysfs    nosuid,noexec,nodev 0     0
devpts         /dev/pts       devpts   gid=5,mode=620      0     0
tmpfs          /run           tmpfs    defaults            0     0
devtmpfs       /dev           devtmpfs mode=0755,nosuid    0     0
tmpfs          /dev/shm       tmpfs    nosuid,nodev        0     0
cgroup2        /sys/fs/cgroup cgroup2  nosuid,noexec,nodev 0     0

# End /etc/fstab
EOF
