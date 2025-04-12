#!/bin/bash
set -euo pipefail

SOURCES=/scripts/blfs/sources/

# TODO summarize kernel build and driver install
#
echo "Installing libnl"
#wget https://github.com/thom311/libnl/releases/download/libnl3_11_0/libnl-3.11.0.tar.gz
#md5sum -c "0a5eb82b494c411931a47638cb0dba51" libnl-3.11.0.tar.gz
pushd ${SOURCES}
tar -zxv libnl-3.11.0.tar.gz
cd libnl-3.11.0
  ./configure --prefix=/usr     \
              --sysconfdir=/etc \
              --disable-static  &&
  make
  make install
cd ..
rm -rf libnl-3.11.0
popd
echo "Done installing libnl"

echo "Installing iw"
#wget https://www.kernel.org/pub/software/network/iw/iw-6.9.tar.xz
#md5sum -c "457c99badf2913bb61a8407ae60e4819" iw-6.9.tar.xz
pushd ${SOURCES}
tar -xvf iw-6.9.tar.xz
cd iw-6.9
  sed -i "/INSTALL.*gz/s/.gz//" Makefile &&
  make
  make install
cd ..
rm -rf iw-6.9
popd
echo "Done Installing iw"

echo "Installing wpa_supplicant"
#wget https://w1.fi/releases/wpa_supplicant-2.11.tar.gz
#md5sum -c "72a4a00eddb7a499a58113c3361ab094" wpa_supplicant-2.11.tar.gz
pushd ${SOURCES}
tar -xvf wpa_supplicant-2.11.tar.gz
cd wpa_supplicant-2.11
  cd wpa_supplicant && make BINDIR=/usr/sbin LIBDIR=/usr/lib
  install -v -m755 wpa_{cli,passphrase,supplicant} /usr/sbin/ &&
  install -v -m644 doc/docbook/wpa_supplicant.conf.5 /usr/share/man/man5/ &&
  install -v -m644 doc/docbook/wpa_{cli,passphrase,supplicant}.8 /usr/share/man/man8/
cd ..
rm -rf wpa_supplicant-2.11
popd
echo "Done installing wpa_supplicant"

echo "Installing dhcpd"
#wget https://github.com/NetworkConfiguration/dhcpcd/releases/download/v10.2.2/dhcpcd-10.2.2.tar.xz
#md5sum -c "417ccbdef28a633e212b4fb59ba06fbf" dhcpcd-10.2.2.tar.xz
pushd ${SOURCES}
tar -xvf dhcpcd-10.2.2.tar.xz
cd dhcpd-10.2.2
./configure --prefix=/usr                \
            --sysconfdir=/etc            \
            --libexecdir=/usr/lib/dhcpcd \
            --dbdir=/var/lib/dhcpcd      \
            --runstatedir=/run           \
            --disable-privsep         &&
make
make install
cd ..
rm -rf dhcpd-10.2.2
popd
echo "Done installing dhcpd"

