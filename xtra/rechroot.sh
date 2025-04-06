#!/bin/bash

set -eu

if [ "$(whoami)" != "root" ]; then
  echo "This script must be run as the 'root' user. Aborting."
  exit 1
fi

echo "Entering chroot environment"
chroot "$LFS" /usr/bin/env -i   \
    HOME=/root                  \
    TERM="$TERM"                \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/usr/bin:/usr/sbin     \
    MAKEFLAGS="-j$(nproc)"      \
    TESTSUITEFLAGS="-j$(nproc)" \
    /bin/bash --login

echo "Tip: To exit chroot later, just type 'exit'"
