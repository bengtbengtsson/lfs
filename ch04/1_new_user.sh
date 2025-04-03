#!/bin/bash

export LFS=/mnt/lfs

groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs

echo "lfs:lfs" | chpasswd

chown -v lfs $LFS/{usr{,/*},var,etc,tools}

chown -v lfs $LFS/lib64

cp -iv ./2_bashs.sh /home/lfs/

echo "NOW RUN 'su - lfs' TO SWITCH TO THE NEW USER"
