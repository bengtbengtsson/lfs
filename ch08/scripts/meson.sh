#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting meson"
tar -xf meson-1.7.0.tar.gz
cd meson-1.7.0

echo "### Building wheel for meson"
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

echo "### Installing meson"
pip3 install --no-index --find-links dist meson

echo "### Installing bash and zsh completions"
install -vDm644 data/shell-completions/bash/meson /usr/share/bash-completion/completions/meson
install -vDm644 data/shell-completions/zsh/_meson /usr/share/zsh/site-functions/_meson

cd ..
rm -rf meson-1.7.0
popd
