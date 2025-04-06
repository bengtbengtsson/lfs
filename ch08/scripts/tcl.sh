#!/bin/bash
set -eu

echo "### Entering /sources"
pushd /sources

echo "### Extracting tcl"
tar -xf tcl8.6.16-src.tar.gz
cd tcl8.6.16

echo "### Building tcl in 'unix' subdir"
SRCDIR=$(pwd)
cd unix

echo "### Configuring tcl"
./configure --prefix=/usr \
            --mandir=/usr/share/man \
            --disable-rpath

echo "### Building tcl"
make

echo "### Fixing config files to avoid hardcoded build paths"
sed -e "s|$SRCDIR/unix|/usr/lib|" \
    -e "s|$SRCDIR|/usr/include|"  \
    -i tclConfig.sh

sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.10|/usr/lib/tdbc1.1.10|" \
    -e "s|$SRCDIR/pkgs/tdbc1.1.10/generic|/usr/include|"    \
    -e "s|$SRCDIR/pkgs/tdbc1.1.10/library|/usr/lib/tcl8.6|" \
    -e "s|$SRCDIR/pkgs/tdbc1.1.10|/usr/include|"            \
    -i pkgs/tdbc1.1.10/tdbcConfig.sh

sed -e "s|$SRCDIR/unix/pkgs/itcl4.3.2|/usr/lib/itcl4.3.2|" \
    -e "s|$SRCDIR/pkgs/itcl4.3.2/generic|/usr/include|"    \
    -e "s|$SRCDIR/pkgs/itcl4.3.2|/usr/include|"            \
    -i pkgs/itcl4.3.2/itclConfig.sh

unset SRCDIR

echo "### Running tcl test suite"
make test

echo "### Installing tcl"
make install

echo "### Making tcl shared lib writable"
chmod -v u+w /usr/lib/libtcl8.6.so

echo "### Installing private headers"
make install-private-headers

echo "### Creating symlink for tclsh"
ln -sfv tclsh8.6 /usr/bin/tclsh

echo "### Renaming conflicting man page"
mv /usr/share/man/man3/{Thread,Tcl_Thread}.3

echo "### Installing optional HTML docs"
cd ..
tar -xf ../tcl8.6.16-html.tar.gz --strip-components=1
mkdir -v -p /usr/share/doc/tcl-8.6.16
cp -v -r ./html/* /usr/share/doc/tcl-8.6.16

cd /sources
rm -rf tcl8.6.16
popd
