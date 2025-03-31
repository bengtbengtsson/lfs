#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting Util-linux"
tar -xf util-linux-2.40.4.tar.xz
cd util-linux-2.40.4

echo "### Configuring Util-linux"
./configure --bindir=/usr/bin     \
            --libdir=/usr/lib     \
            --runstatedir=/run    \
            --sbindir=/usr/sbin   \
            --disable-chfn-chsh   \
            --disable-login       \
            --disable-nologin     \
            --disable-su          \
            --disable-setpriv     \
            --disable-runuser     \
            --disable-pylibmount  \
            --disable-liblastlog2 \
            --disable-static      \
            --without-python      \
            --without-systemd     \
            --without-systemdsystemunitdir        \
            ADJTIME_PATH=/var/lib/hwclock/adjtime \
            --docdir=/usr/share/doc/util-linux-2.40.4

echo "### Building Util-linux"
make

#echo "### Preparing for tests"
#touch /etc/fstab
#chown -R tester .

#echo "### Running Util-linux test suite"
#su tester -c "make -k check" || true

echo "### Installing Util-linux"
make install

cd ..
rm -rf util-linux-2.40.4
popd
