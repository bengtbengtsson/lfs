#!/bin/bash

set -eu

if [ "$(whoami)" != "root" ]; then
  echo "This script must be run as the 'root' user. Aborting."
  exit 1
fi

echo "📌 Bringing up the LFS system in development mode"

# Load environment
echo "🔧 Loading LFS environment..."
. /mnt/lfs/sources/.lfsenv || {
  echo "❌ Could not load LFS environment from .lfsenv"
  exit 1
}

echo
echo "🔍 Active LFS environment variables:"
env | grep LFS_ | sort

# Mount root
echo "🔧 Mounting root partition: $LFS_ROOT → $LFS"
mkdir -pv "$LFS"
if ! mountpoint -q "$LFS"; then
  mount -t ext4 "$LFS_ROOT" "$LFS"
else
  echo "✅ $LFS already mounted"
fi

# Mount boot
echo "🔧 Mounting boot partition: $LFS_BOOT → $LFS/boot"
mkdir -pv "$LFS/boot"
if ! mountpoint -q "$LFS/boot"; then
  mount -t vfat "$LFS_BOOT" "$LFS/boot"
else
  echo "✅ $LFS/boot already mounted"
fi

# Set umask
echo "🔧 Setting umask to 022"
umask 022

# Mount virtual filesystems
echo "🔧 Mounting virtual filesystems..."

if ! mountpoint -q "$LFS/dev"; then
  mount -v --bind /dev "$LFS/dev"
fi

if ! mountpoint -q "$LFS/dev/pts"; then
  mount -vt devpts devpts -o gid=5,mode=0620 "$LFS/dev/pts"
fi

if ! mountpoint -q "$LFS/proc"; then
  mount -vt proc proc "$LFS/proc"
fi

if ! mountpoint -q "$LFS/sys"; then
  mount -vt sysfs sysfs "$LFS/sys"
fi

if ! mountpoint -q "$LFS/run"; then
  mount -vt tmpfs tmpfs "$LFS/run"
fi

echo
echo "✅ All mounts complete."
echo "🔁 You are now ready to run: ./rechroot.sh"
echo "📎 Tip: Run 'mount | grep $LFS' to verify mount points"

