#!/bin/bash
set -e

export LFS=/mnt/lfs
LFS_DISK="$1"

partition_suffix() {
    case "$1" in
        *[0-9]) echo "p" ;;  # For nvme0n1 → p
        *) echo "" ;;
    esac
}

if [ -z "$LFS_DISK" ]; then
    echo "Usage: $0 <device>"
    exit 1
fi

echo "Creating GPT partition table on $LFS_DISK..."
parted -s "$LFS_DISK" mklabel gpt

echo "Creating EFI System Partition (100MB)..."
parted -s "$LFS_DISK" mkpart ESP fat32 1MiB 101MiB
parted -s "$LFS_DISK" set 1 esp on

echo "Creating swap partition (1GB)..."
parted -s "$LFS_DISK" mkpart primary linux-swap 101MiB 1125MiB

echo "Creating root partition (rest of disk)..."
parted -s "$LFS_DISK" mkpart primary ext4 1125MiB 100%

echo "Formatting partitions..."
P=$(partition_suffix "$LFS_DISK")
mkfs.fat -F32 "${LFS_DISK}${P}1"
mkswap "${LFS_DISK}2"
mkfs.ext4 -F "${LFS_DISK}${P}3"

echo "Disk setup complete (GPT)."
