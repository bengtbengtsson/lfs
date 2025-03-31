#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting readline"
tar -xf readline-8.2.13.tar.gz
cd readline-8.2.13

echo "### Applying sed fixes"
sed -i '/MV.*old/d' Makefile.in
sed -i '/{OLDSUFF}/c:' support/shlib-install
sed -i 's/-Wl,-rpath,[^ ]*//' support/shobj-conf

echo "### Configuring readline"
./configure --prefix=/usr    \
            --disable-static \
            --with-curses    \
            --docdir=/usr/share/doc/readline-8.2.13

echo "### Building readline"
make SHLIB_LIBS="-lncursesw"

echo "### Installing readline"
make install

echo "### Installing optional docs"
install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.2.13

cd ..
rm -rf readline-8.2.13
popd

