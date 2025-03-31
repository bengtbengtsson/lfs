#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting shadow"
tar -xf shadow-4.17.3.tar.xz
cd shadow-4.17.3

echo "### Disabling unwanted programs and man pages"
sed -i 's/groups$(EXEEXT) //' src/Makefile.in
find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;

echo "### Enabling YESCRYPT and adjusting defaults"
sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD YESCRYPT:' \
    -e 's:/var/spool/mail:/var/mail:'                   \
    -e '/PATH=/{s@/sbin:@@;s@/bin:@@}'                   \
    -i etc/login.defs

echo "### Creating stub for /usr/bin/passwd"
touch /usr/bin/passwd

echo "### Configuring shadow"
./configure --sysconfdir=/etc   \
            --disable-static    \
            --with-{b,yes}crypt \
            --without-libbsd    \
            --with-group-name-max-length=32

echo "### Building shadow"
make

echo "### Installing shadow"
make exec_prefix=/usr install
make -C man install-man

echo "### Enabling shadowed password and group support"
pwconv
grpconv

echo "### Setting useradd default group"
mkdir -p /etc/default
useradd -D --gid 999

echo "### Setting root password non-interactively"
echo "root:root" | chpasswd

cd ..
rm -rf shadow-4.17.3
popd
