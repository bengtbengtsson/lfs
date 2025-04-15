#!/bin/bash
set -euo pipefail

echo "Installing nerdfont"

mkdir -p /usr/share/fonts/nerdfonts

cd /usr/share/fonts/nerdfonts
wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip
unzip Hack.zip
rm Hack.zip

# rebuild font cache
fc-cache -fv

echo "Listing Hack fonts"
fc-list | grep "Hack"

echo "Done installing nerdfont"

