#!/bin/bash
set -eu

echo "### Entering /sources"
pushd /sources

echo "### Extracting gcc"
tar -xf gcc-14.2.0.tar.xz
cd gcc-14.2.0

echo "### Applying multilib workaround for x86_64"
case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
  ;;
esac

echo "### Creating build directory for gcc"
mkdir -v build
cd build

echo "### Configuring gcc"
../configure --prefix=/usr            \
             LD=ld                    \
             --enable-languages=c,c++ \
             --enable-default-pie     \
             --enable-default-ssp     \
             --enable-host-pie        \
             --disable-multilib       \
             --disable-bootstrap      \
             --disable-fixincludes    \
             --with-system-zlib

echo "### Building gcc"
make

echo "### Fixing known test issues"
sed -e '/cpython/d'               -i ../gcc/testsuite/gcc.dg/plugin/plugin.exp
sed -e 's/no-pic /&-no-pie /'     -i ../gcc/testsuite/gcc.target/i386/pr113689-1.c
sed -e 's/300000/(1|300000)/'     -i ../libgomp/testsuite/libgomp.c-c++-common/pr109062.c
sed -e 's/{ target nonpic } //' \
    -e '/GOTPCREL/d'              -i ../gcc/testsuite/gcc.target/i386/fentryname3.c

echo "### Setting hard stack limit (ulimit)"
ulimit -s -H unlimited

echo "### Running gcc test suite as tester user"
chown -R tester .
su tester -c "PATH=$PATH make -k check"

echo "### Test summary"
../contrib/test_summary | tee ../test_summary.log

echo "### Installing gcc"
make install

echo "### Fixing permissions on include dir"
chown -v -R root:root /usr/lib/gcc/$(gcc -dumpmachine)/14.2.0/include{,-fixed}

echo "### Creating cpp symlink"
ln -svr /usr/bin/cpp /usr/lib

echo "### Creating cc.1 manpage symlink"
ln -sv gcc.1 /usr/share/man/man1/cc.1

echo "### Creating liblto_plugin.so symlink"
ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/14.2.0/liblto_plugin.so \
        /usr/lib/bfd-plugins/

echo "### Performing sanity checks"
echo 'int main(){}' > dummy.c
cc dummy.c -v -Wl,--verbose &> dummy.log
readelf -l a.out | grep ': /lib'
grep -E -o '/usr/lib.*/S?crt[1in].*succeeded' dummy.log
grep -B4 '^ /usr/include' dummy.log
grep 'SEARCH.*/usr/lib' dummy.log | sed 's|; |\n|g'
grep "/lib.*/libc.so.6 " dummy.log
grep found dummy.log
rm -v dummy.c a.out dummy.log

echo "### Moving gdb auto-load python files"
mkdir -pv /usr/share/gdb/auto-load/usr/lib
mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib

cd /sources
rm -rf gcc-14.2.0
popd
