#!/bin/bash
set -euo pipefail

# TODO summarize kernel build and driver install
#
echo "Installing libnl"
wget https://github.com/thom311/libnl/releases/download/libnl3_11_0/libnl-3.11.0.tar.gz
md5sum -c "0a5eb82b494c411931a47638cb0dba51" libnl-3.11.0.tar.gz
tar -zxv libnl-3.11.0.tar.gz
pushd libnl-3.11.0
  ./configure --prefix=/usr     \
              --sysconfdir=/etc \
              --disable-static  &&
  make
  make install
popd
rm -rf libnl-3.11.0
echo "Done installing libnl"

echo "Installing iw"
wget https://www.kernel.org/pub/software/network/iw/iw-6.9.tar.xz
md5sum -c "457c99badf2913bb61a8407ae60e4819" iw-6.9.tar.xz
tar -xvf iw-6.9.tar.xz
pushd iw-6.9
  sed -i "/INSTALL.*gz/s/.gz//" Makefile &&
  make
  make install
popd
rm -rf iw-6.9
echo "Done Installing iw"
# wpa-supplicant
#
#
# dhcpcd
