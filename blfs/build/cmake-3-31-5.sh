#!/bin/bash
set -euo pipefail

SOURCES=/scripts/blfs/sources/

pushd "$SOURCES" > /dev/null
echo "Extracting CMake-3.31.5..."
tar xf cmake-3.31.5.tar.gz
cd cmake-3.31.5

echo "Configuring CMake installation..."
sed -i '/"lib64"/s/64//' Modules/GNUInstallDirs.cmake
./bootstrap --prefix=/usr        \
            --system-libs        \
            --mandir=/share/man  \
            --no-system-jsoncpp  \
            --no-system-cppdap   \
            --no-system-librhash \
            --docdir=/share/doc/cmake-3.31.5

echo "Building CMake..."
make

echo "Installing CMake..."
make install

cd ..
rm -rf cmake-3.31.5
popd > /dev/null

echo "Done installing CMake-3.31.5"
