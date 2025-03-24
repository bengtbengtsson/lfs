#!/bin/bash

set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <device>"
      exit 1
fi

export LFS=/mnt/lfs
export LFS_TGT=x86_64-lfs-linux-gnu
export LFS_DISK="$1"
umask 022

if ! mountpoint -q "$LFS"; then
  source setupdisk.sh "$LFS_DISK" # TODO do we really need 'source' here?
  mkdir -pv "$LFS"
  mount "${LFS_DISK}3" "$LFS" # TODO This will not work on nvme0n1p1 etc
fi

mkdir -pv $LFS/tools 
mkdir -pv $LFS/sources

mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}
mkdir -pv $LFS/lib64

for i in bin lib sbin; do
    ln -sv usr/$i $LFS/$i
done

mkdir -pv $LFS/boot 

mount -v -t ext4 "${LFS_DISK}1" $LFS/boot
chown root:root $LFS
chmod 755 $LFS

swapon -v "${LFS_DISK}2"
