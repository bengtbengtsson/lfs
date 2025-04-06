#!/bin/bash
set -eu

echo "### Entering /sources"
pushd /sources

echo "### Extracting python"
tar -xf Python-3.13.2.tar.xz
cd Python-3.13.2

echo "### Configuring python"
./configure --prefix=/usr        \
            --enable-shared      \
            --with-system-expat  \
            --enable-optimizations

echo "### Building python"
make

echo "### Running python test suite"
make test TESTOPTS="--timeout 120" || echo "Some tests may fail safely"

echo "### Installing python"
make install

echo "### Suppressing pip3 root-user and version warnings"
cat > /etc/pip.conf << "EOF"
[global]
root-user-action = ignore
disable-pip-version-check = true
EOF

echo "### Installing Python documentation (optional)"
install -v -dm755 /usr/share/doc/python-3.13.2/html
tar --strip-components=1  \
    --no-same-owner       \
    --no-same-permissions \
    -C /usr/share/doc/python-3.13.2/html \
    -xvf ../python-3.13.2-docs-html.tar.bz2

cd ..
rm -rf Python-3.13.2
popd
