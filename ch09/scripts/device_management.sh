#!/bin/bash
set -eu

# create custom udev rules
bash /usr/lib/udev/init-net-rules.sh

cd /etc/sysconfig/
cat > ifconfig.eth0 << "EOF"
ONBOOT=yes
IFACE=eth0
SERVICE=ipv4-static
IP=192.168.1.210
GATEWAY=192.168.1.1
PREFIX=24
BROADCAST=192.168.1.255
EOF

cat > /etc/resolv.conf << "EOF"
# Begin /etc/resolv.conf

#domain <Your Domain Name>
nameserver 192.168.1.1
nameserver 8.8.8.8
nameserver 1.1.1.1

# End /etc/resolv.conf
EOF

echo "lfs" > /etc/hostname

cat > /etc/hosts << "EOF"
# Begin /etc/hosts

127.0.0.1 localhost.localdomain localhost
127.0.1.1 lfs.home lfs
192.168.1.210 lfs.home lfs

# End /etc/hosts
EOF
