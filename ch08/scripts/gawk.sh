#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting Gawk"
tar -xf gawk-5.3.1.tar.xz
cd gawk-5.3.1

echo "### Preventing unneeded files from being installed"
sed -i 's/extras//' Makefile.in

echo "### Configuring Gawk"
./configure --prefix=/usr

echo "### Building Gawk"
make

echo "### Running tests for Gawk"
chown -R tester .
su tester -c "PATH=$PATH make check"

echo "### Installing Gawk"
rm -f /usr/bin/gawk-5.3.1
make install
ln -sv gawk.1 /usr/share/man/man1/awk.1

echo "### (Optional) Installing Gawk documentation"
install -vDm644 doc/{awkforai.txt,*.{eps,pdf,jpg}} -t /usr/share/doc/gawk-5.3.1

cd ..
rm -rf gawk-5.3.1
popd
