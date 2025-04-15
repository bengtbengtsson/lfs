#!/bin/bash
set -euo pipefail

SOURCES=/scripts/blfs/sources/

echo "Installing sudo"
pushd ${SOURCES}
  tar -xvf sudo-1.9.16p2.tar.gz 
  cd sudo-1.9.16p2
 
  ./configure --prefix=/usr              \
            --libexecdir=/usr/lib      \
            --with-secure-path         \
            --with-env-editor          \
            --docdir=/usr/share/doc/sudo-1.9.16p2 \
            --with-passprompt="[sudo] password for %p: " &&
  make
  make install
    
  cd ..
  rm -rf sudo-1.9.16p2
popd

cat > /etc/sudoers.d/00-sudo << "EOF"
Defaults secure_path="/usr/sbin:/usr/bin"
%wheel ALL=(ALL) ALL
EOF

echo "Done installing sudo"


