#!/bin/bash
set -e

. /sources/.lfsenv || {
  echo "❌ Could not load LFS environment."
  exit 1
}

echo "### Entering /sources"
pushd /sources

echo "### Extracting GRUB"
tar -xf grub-2.12.tar.xz
cd grub-2.12

echo "### Unsetting environment flags for GRUB build"
unset {C,CPP,CXX,LD}FLAGS

echo "### Creating missing extra_deps.lst"
echo depends bli part_gpt > grub-core/extra_deps.lst

if [ "$LFS_PART_SCHEME" = "gpt" ]; then
  ./configure --prefix=/usr \
              --sysconfdir=/etc \
              --disable-efiemu \
              --with-platform=efi \
              --target=x86_64 \
              --disable-werror
else
  ./configure --prefix=/usr \
              --sysconfdir=/etc \
              --disable-efiemu \
              --target=i386-pc \
              --disable-werror
fi

echo "### Building GRUB"
make

echo "### Installing GRUB"
make install

echo "### Moving bash completion"
mv -v /etc/bash_completion.d/grub /usr/share/bash-completion/completions

cd ..
rm -rf grub-2.12
popd
