#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting GRUB"
tar -xf grub-2.12.tar.xz
cd grub-2.12

echo "### Unsetting environment flags for GRUB build"
unset {C,CPP,CXX,LD}FLAGS

echo "### Creating missing extra_deps.lst"
echo depends bli part_gpt > grub-core/extra_deps.lst

echo "### Configuring GRUB"
./configure --prefix=/usr          \
            --sysconfdir=/etc      \
            --disable-efiemu       \
            --disable-werror

echo "### Building GRUB"
make

echo "### Installing GRUB"
make install

echo "### Moving bash completion"
mv -v /etc/bash_completion.d/grub /usr/share/bash-completion/completions

cd ..
rm -rf grub-2.12
popd
