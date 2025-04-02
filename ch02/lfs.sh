#!/bin/bash

set -e

# --- Argument validation ---
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <device> <mbr|gpt>"
    exit 1
fi

LFS_DISK="$1"
PARTITION_SCHEME="$2"

if [[ "$PARTITION_SCHEME" != "mbr" && "$PARTITION_SCHEME" != "gpt" ]]; then
    echo "Error: Partition scheme must be 'mbr' or 'gpt'"
    exit 1
fi

# --- Environment setup ---
export LFS=/mnt/lfs
export LFS_TGT=x86_64-lfs-linux-gnu
umask 022

# --- Partition setup ---
if ! mountpoint -q "$LFS"; then
    "setupdisk_${PARTITION_SCHEME}.sh" "$LFS_DISK"
    mkdir -pv "$LFS"

    # Adjust partition suffix (e.g., /dev/sda3 or /dev/nvme0n1p3)
    if [[ "$LFS_DISK" =~ nvme ]]; then
        BOOT="${LFS_DISK}p1"
        SWAP="${LFS_DISK}p2"
        ROOT="${LFS_DISK}p3"
    else
        BOOT="${LFS_DISK}1"
        SWAP="${LFS_DISK}2"
        ROOT="${LFS_DISK}3"
    fi

    mount "$ROOT" "$LFS"
    mount -v -t ext4 "$BOOT" "$LFS/boot"
    swapon -v "$SWAP"
fi

# --- Directory layout ---
mkdir -pv $LFS/tools 
mkdir -pv $LFS/sources

mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}
mkdir -pv $LFS/lib64
for i in bin lib sbin; do
    ln -sv usr/$i $LFS/$i
done

chown root:root $LFS
chmod 755 $LFS

