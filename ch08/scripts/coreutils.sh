#!/bin/bash
set -eu

echo "### Entering /sources"
pushd /sources

echo "### Extracting coreutils"
tar -xf coreutils-9.6.tar.xz
cd coreutils-9.6

echo "### Patching for i18n"
patch -Np1 -i ../coreutils-9.6-i18n-1.patch

echo "### Regenerating autotools"
autoreconf -fv
automake -af

echo "### Configuring coreutils"
FORCE_UNSAFE_CONFIGURE=1 ./configure \
    --prefix=/usr \
    --enable-no-install-program=kill,uptime

echo "### Building coreutils"
make

echo "### Running root tests"
make NON_ROOT_USERNAME=tester check-root

echo "### Creating dummy group and fixing permissions"
groupadd -g 102 dummy -U tester
chown -R tester .

echo "### Running non-root tests"
su tester -c "PATH=$PATH make -k RUN_EXPENSIVE_TESTS=yes check" < /dev/null

echo "### Removing dummy group"
groupdel dummy

echo "### Installing coreutils"
make install

echo "### Moving chroot binary and man page per FHS"
mv -v /usr/bin/chroot /usr/sbin
mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8

cd ..
rm -rf coreutils-9.6
popd
