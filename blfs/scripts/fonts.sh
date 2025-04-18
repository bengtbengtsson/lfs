#!/bin/bash
set -euo pipefail

echo "The wgets does not work"
echo "I have copied and installed the ter-* files manually"
echo "We are using ter-132-n as default consolefont"

if false; then
echo "👉 Downloading Terminus PSF fonts"
mkdir -p /usr/share/consolefonts
cd /usr/share/consolefonts

wget https://terminus-font.sourceforge.net/ttf/console/ter-u32n.psf.gz
wget https://terminus-font.sourceforge.net/ttf/console/ter-132n.psf.gz

echo "👉 Unpacking fonts"
gunzip -f ter-u32n.psf.gz
gunzip -f ter-132n.psf.gz

echo "👉 Setting font now"
setfont ter-132n.psf || {
  echo "⚠️ setfont failed, try another like ter-u32n.psf"
}

cat >> /etc/sysconfig/console <<EOF
FONT=ter-132n.psf
EOF


echo "✅ Terminus font installed and configured."
fi
