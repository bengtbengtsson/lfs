#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting bash"
tar -xf bash-5.2.37.tar.gz
cd bash-5.2.37

echo "### Configuring bash"
./configure --prefix=/usr             \
            --without-bash-malloc     \
            --with-installed-readline \
            --docdir=/usr/share/doc/bash-5.2.37

echo "### Building bash"
make

echo "### Preparing to run bash test suite"
chown -R tester .

su -s /usr/bin/expect tester << "EOF"
set timeout -1
spawn make tests
expect eof
lassign [wait] _ _ _ value
exit $value
EOF

echo "### Installing bash"
make install

echo "### Note: New Bash installed. Will be active on next login shell."
# echo "To activate immediately, run: exec /usr/bin/bash --login"

cd ..
rm -rf bash-5.2.37
popd
