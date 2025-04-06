#!/bin/bash
set -eu

export LFS=/mnt/lfs
LFS_DISK="$1"

if [ -z "$LFS_DISK" ]; then
    echo "Usage: $0 <device>"
    exit 1
fi

# Returns partition suffix (e.g., "" or "p") based on disk name
partition_suffix() {
    case "$1" in
        *[0-9]) echo "p" ;;  # e.g. /dev/nvme0n1
        *) echo "" ;;
    esac
}

echo "Creating MBR partition table on $LFS_DISK..."
parted -s "$LFS_DISK" mklabel msdos

echo "Creating boot partition (100MB)..."
parted -s "$LFS_DISK" mkpart primary ext4 1MiB 101MiB
parted -s "$LFS_DISK" set 1 boot on

echo "Creating swap partition (1GB)..."
parted -s "$LFS_DISK" mkpart primary linux-swap 101MiB 1125MiB

echo "Creating root partition (rest of disk)..."
parted -s "$LFS_DISK" mkpart primary ext4 1125MiB 100%

echo "Formatting partitions..."
P=$(partition_suffix "$LFS_DISK")
mkfs.ext4 -F "${LFS_DISK}${P}1"
mkswap "${LFS_DISK}2"
mkfs.ext4 -F "${LFS_DISK}${P}3"

echo "Disk setup complete (MBR)."
