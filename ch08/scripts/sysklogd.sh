#!/bin/bash
set -eu

echo "### Entering /sources"
pushd /sources

echo "### Extracting Sysklogd"
tar -xf sysklogd-2.7.0.tar.gz
cd sysklogd-2.7.0

echo "### Configuring Sysklogd"
./configure --prefix=/usr      \
            --sysconfdir=/etc  \
            --runstatedir=/run \
            --without-logger   \
            --disable-static   \
            --docdir=/usr/share/doc/sysklogd-2.7.0

echo "### Building Sysklogd"
make

echo "### Installing Sysklogd"
make install

echo "### Creating /etc/syslog.conf"
cat > /etc/syslog.conf << "EOF"
# Begin /etc/syslog.conf

auth,authpriv.* -/var/log/auth.log
*.*;auth,authpriv.none -/var/log/sys.log
daemon.* -/var/log/daemon.log
kern.* -/var/log/kern.log
mail.* -/var/log/mail.log
user.* -/var/log/user.log
*.emerg *

# Do not open any internet ports.
secure_mode 2

# End /etc/syslog.conf
EOF

cd ..
rm -rf sysklogd-2.7.0
popd
