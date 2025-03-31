#!/bin/bash
# This script is used to control tha various scripts in ch07
# This script should be run as the root user

set -e

if [ "$USER" != "root" ]; then
  echo "This script must be run as the 'root' user. Aborting."
  exit 1
fi

export LFS=/mnt/lfs
export LFS_TGT=$(uname -m)-lfs-linux-gnu

# 7.2 changing ownership
chown --from lfs -R root:root $LFS/{usr,lib,var,etc,bin,sbin,tools}
case $(uname -m) in
  x86_64) chown --from lfs -R root:root $LFS/lib64 ;;
esac

# 7.3 preparing virtual kernel file systems
mkdir -pv $LFS/{dev,proc,sys,run}

mount -v --bind /dev $LFS/dev

mount -vt devpts devpts -o gid=5,mode=0620 $LFS/dev/pts
mount -vt proc proc $LFS/proc
mount -vt sysfs sysfs $LFS/sys
mount -vt tmpfs tmpfs $LFS/run

if [ -h $LFS/dev/shm ]; then
  install -v -d -m 1777 $LFS$(realpath /dev/shm)
else
  mount -vt tmpfs -o nosuid,nodev tmpfs $LFS/dev/shm
fi

# 7.4 entering the chroot environment
chroot "$LFS" /usr/bin/env -i   \
    HOME=/root                  \
    TERM="$TERM"                \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/usr/bin:/usr/sbin     \
    MAKEFLAGS="-j$(nproc)"      \
    TESTSUITEFLAGS="-j$(nproc)" \
    /bin/bash --login
