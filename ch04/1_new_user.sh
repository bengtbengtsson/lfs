#!/bin/bash

export LFS=/mnt/lfs

groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs

echo "lfs:lfs" | chpasswd

# Set correct ownership for required directories
chown -v lfs $LFS/{usr{,/*},var,etc,tools,lib64}

# Move your scripts into /mnt/lfs/sources/scripts (or just /mnt/lfs/scripts if preferred)
mkdir -pv $LFS/sources/scripts
cp -r /root/lfs/* $LFS/sources/scripts
chown -R lfs:lfs $LFS/sources/scripts

# Optional: create a symlink in /home/lfs for convenience
ln -sv $LFS/sources/scripts /home/lfs/lfs-scripts
chown -h lfs:lfs /home/lfs/lfs-scripts

echo "✅ Done. Now run: su - lfs"

