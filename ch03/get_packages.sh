#!/bin/bash

export LFS=/mnt/lfs

set -e

chmod -v a+wt $LFS/sources

wget --input-file=wget-list-sysv --continue --directory-prefix=$LFS/sources

pushd $LFS/sources
  md5sum -c md5sums
popd

# copy md5sums to sources

chown root:root $LFS/sources/*
