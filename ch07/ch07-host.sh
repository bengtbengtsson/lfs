#!/bin/bash
# This script is used to control the various scripts in ch07
# This script should be run as the root user

set -eu

if [ "$(whoami)" != "root" ]; then
  echo "❌ This script must be run as the 'root' user. Aborting."
  exit 1
fi

export LFS=/mnt/lfs
export LFS_TGT=$(uname -m)-lfs-linux-gnu

# 7.2 Changing ownership
chown --from lfs -R root:root $LFS/{usr,lib,var,etc,bin,sbin,tools}
case $(uname -m) in
  x86_64) chown --from lfs -R root:root $LFS/lib64 ;;
esac

# 7.3 Preparing virtual kernel file systems
mkdir -pv $LFS/{dev,proc,sys,run}

if ! mountpoint -q $LFS/dev; then
  mount -v --bind /dev $LFS/dev
else
  echo "ℹ️  $LFS/dev already mounted."
fi

if ! mountpoint -q $LFS/dev/pts; then
  mount -vt devpts devpts -o gid=5,mode=0620 $LFS/dev/pts
else
  echo "ℹ️  $LFS/dev/pts already mounted."
fi

if ! mountpoint -q $LFS/proc; then
  mount -vt proc proc $LFS/proc
else
  echo "ℹ️  $LFS/proc already mounted."
fi

if ! mountpoint -q $LFS/sys; then
  mount -vt sysfs sysfs $LFS/sys
else
  echo "ℹ️  $LFS/sys already mounted."
fi

if ! mountpoint -q $LFS/run; then
  mount -vt tmpfs tmpfs $LFS/run
else
  echo "ℹ️  $LFS/run already mounted."
fi

if [ -h $LFS/dev/shm ]; then
  install -v -d -m 1777 $LFS$(realpath /dev/shm)
else
  if ! mountpoint -q $LFS/dev/shm; then
    mount -vt tmpfs -o nosuid,nodev tmpfs $LFS/dev/shm
  else
    echo "ℹ️  $LFS/dev/shm already mounted."
  fi
fi

# 7.4 Entering the chroot environment
echo "🔒 Entering chroot..."
chroot "$LFS" /usr/bin/env -i   \
    HOME=/root                  \
    TERM="$TERM"                \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/usr/bin:/usr/sbin     \
    MAKEFLAGS="-j$(nproc)"      \
    TESTSUITEFLAGS="-j$(nproc)" \
    /bin/bash --login

