#!/bin/bash

echo "Once the /mnt/lfs is created, cd into directory and"
echo "git clone https://github.com/bengtbengtsson/lfs.git scripts"

set -eu

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
    "./setupdisk_${PARTITION_SCHEME}.sh" "$LFS_DISK"
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

    mkdir -pv "$LFS/boot"

    if [ "$PARTITION_SCHEME" = "mbr" ]; then
        mount -v -t ext4 "$BOOT" "$LFS/boot"
    else
        mount -v -t vfat "$BOOT" "$LFS/boot"
    fi
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

# --- Save environment for future scripts ---
export BOOT_UUID=$(blkid -s UUID -o value ${LFS_BOOT})
export SWAP_UUID=$(blkid -s UUID -o value ${LFS_SWAP})
export ROOT_UUID=$(blkid -s UUID -o value ${LFS_ROOT})

cat > "$LFS/sources/.lfsenv" << EOF
# Automatically generated by LFS setup script
export LFS=/mnt/lfs
export LFS_DISK=$LFS_DISK
export LFS_TGT=$LFS_TGT
export LFS_PARTITION_SCHEME=$PARTITION_SCHEME
export LFS_GRUB_ID=LFS
export BOOT_UUID=$BOOT_UUID
export SWAP_UUID=$SWAP_UUID
export ROOT_UUID=$ROOT_UUID

if [[ "\$LFS_DISK" =~ nvme ]]; then
  export LFS_BOOT="\${LFS_DISK}p1"
  export LFS_SWAP="\${LFS_DISK}p2"
  export LFS_ROOT="\${LFS_DISK}p3"
else
  export LFS_BOOT="\${LFS_DISK}1"
  export LFS_SWAP="\${LFS_DISK}2"
  export LFS_ROOT="\${LFS_DISK}3"
fi
EOF

echo "✅ Environment written to $LFS/sources/.lfsenv"

