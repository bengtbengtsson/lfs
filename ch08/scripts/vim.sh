#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting Vim"
tar -xf vim-9.1.1166.tar.gz
cd vim-9.1.1166

echo "### Setting sys vimrc path"
echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h

echo "### Configuring Vim"
./configure --prefix=/usr

echo "### Building Vim"
make

echo "### Preparing for tests"
chown -R tester .
sed '/test_plugin_glvs/d' -i src/testdir/Make_all.mak

echo "### Running Vim test suite (output redirected)"
su tester -c "TERM=xterm-256color LANG=en_US.UTF-8 make -j1 test" &> vim-test.log || true

echo "### Installing Vim"
make install

echo "### Creating vi symlinks"
ln -sv vim /usr/bin/vi
for L in /usr/share/man/{,*/}man1/vim.1; do
    ln -sv vim.1 $(dirname $L)/vi.1
done

echo "### Creating doc symlink"
ln -sv ../vim/vim91/doc /usr/share/doc/vim-9.1.1166

cd ..
rm -rf vim-9.1.1166
popd
