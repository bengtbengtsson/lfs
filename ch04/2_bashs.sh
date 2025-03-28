#!/bin/bash

cat > ~/.bash_profile << "EOF"
echo "Setting up bash profile"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

cat > ~/.bashrc << "EOF"
echo "Setting up bashrc"
set +h
umask 022
export LFS=/mnt/lfs
LC_ALL=POSIX
export LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE

export MAKEFLAGS=-j8
EOF


echo "Now type 'source ~/.bash_profile' to apply the changes"


