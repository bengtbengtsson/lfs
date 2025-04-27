#!/bin/bash
set -euo pipefail

SOURCES=/scripts/blfs/sources/

echo "Installing git"
pushd ${SOURCES}
  tar -xvf git-2.48.1.tar.xz 
  cd git-2.48.1
  
  ./configure --prefix=/usr \
            --with-gitconfig=/etc/gitconfig \
            --with-python=python3 &&
  make
  make perllibdir=/usr/lib/perl5/5.40/site_perl install

  cd ..
  rm -rf git-2.48.1 
popd

echo "Done installing git"

