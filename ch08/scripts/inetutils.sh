#!/bin/bash
set -eu

echo "### Entering /sources"
pushd /sources

echo "### Extracting inetutils"
tar -xf inetutils-2.6.tar.xz
cd inetutils-2.6

echo "### Patching for gcc >= 14"
sed -i 's/def HAVE_TERMCAP_TGETENT/ 1/' telnet/telnet.c

echo "### Configuring inetutils"
./configure --prefix=/usr        \
            --bindir=/usr/bin    \
            --localstatedir=/var \
            --disable-logger     \
            --disable-whois      \
            --disable-rcp        \
            --disable-rexec      \
            --disable-rlogin     \
            --disable-rsh        \
            --disable-servers

echo "### Building inetutils"
make

echo "### Running inetutils test suite"
make check

echo "### Installing inetutils"
make install

echo "### Moving ifconfig to /sbin"
mv -v /usr/{,s}bin/ifconfig

cd ..
rm -rf inetutils-2.6
popd
