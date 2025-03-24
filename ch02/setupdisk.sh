#!/bin/bash

export LFS=/mnt/lfs
LFS_DISK="$1"

# if needed, prepare the disk with: dd if=/dev/zero of="$LFS_DISK" bs=1M count=10
# this will hopefully wipe the disk from partition signature

fdisk "$LFS_DISK" <<EOF
o
n
p
1

+100M
a
n
p
2

+1G
t
2
82
n
p



w
EOF

mkfs -v -t ext4 "${LFS_DISK}1"
mkfs -v -t ext4 "${LFS_DISK}3"
mkswap "${LFS_DISK}2"
