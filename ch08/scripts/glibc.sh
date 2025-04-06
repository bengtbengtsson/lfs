#!/bin/bash
set -eu

echo "### Entering /sources"
pushd /sources

echo "### Extracting Glibc"
tar -xf glibc-2.41.tar.xz
cd glibc-2.41

echo "### Applying FHS patch"
patch -Np1 -i ../glibc-2.41-fhs-1.patch

echo "### Creating build dir"
mkdir -v build
cd build

echo "### Setting rootsbindir for ldconfig/sln"
echo "rootsbindir=/usr/sbin" > configparms

echo "### Configuring Glibc"
../configure --prefix=/usr \
             --disable-werror \
             --enable-kernel=5.4 \
             --enable-stack-protector=strong \
             --disable-nscd \
             libc_cv_slibdir=/usr/lib

echo "### Compiling Glibc"
make -j$(nproc)

echo "### Running Glibc test suite (can be slow)"
make check

echo "### Prevent warning about missing /etc/ld.so.conf"
touch /etc/ld.so.conf

echo "### Skipping outdated sanity check"
sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile

echo "### Installing Glibc"
make install

echo "### Fixing hardcoded loader path in ldd"
sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd

echo "### Installing minimal locales"
localedef -i C -f UTF-8 C.UTF-8
localedef -i en_US -f UTF-8 en_US.UTF-8

echo "### Creating /etc/nsswitch.conf"
cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf
passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files
# End /etc/nsswitch.conf
EOF

echo "### Installing timezone data"
tar -xf ../../tzdata2025a.tar.gz

ZONEINFO=/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}

for tz in etcetera southamerica northamerica europe africa antarctica asia australasia backward; do
  zic -L /dev/null   -d $ZONEINFO       ${tz}
  zic -L /dev/null   -d $ZONEINFO/posix ${tz}
  zic -L leapseconds -d $ZONEINFO/right ${tz}
done

cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
zic -d $ZONEINFO -p Europe/Stockholm

ln -sfv /usr/share/zoneinfo/Europe/Stockholm /etc/localtime

unset ZONEINFO tz

echo "### Configuring dynamic linker search paths"
cat > /etc/ld.so.conf << "EOF"
/usr/local/lib
/opt/lib
EOF

cat >> /etc/ld.so.conf << "EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf
EOF

mkdir -pv /etc/ld.so.conf.d

cd /sources
rm -rf glibc-2.41

popd
