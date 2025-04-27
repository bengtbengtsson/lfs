#!/bin/bash
set -euo pipefail

SOURCES=/scripts/blfs/sources/

# TODO summarize kernel build and driver install
#
echo "Installing wget"
pushd ${SOURCES}
  tar -xvf wget-1.25.0.tar.gz
  cd wget-1.25.0
  
  ./configure --prefix=/usr      \
            --sysconfdir=/etc  \
            --with-ssl=openssl &&
  make

  make install
    
  cd ..
  rm -rf wget-1.25.0
popd

echo "Installing certs"
install -v -d -m755 /etc/ssl/certs
cp -v /scripts/blfs/sources/cacert.pem /etc/ssl/certs/ca-certificates.crt

echo "ca_certificate=/etc/ssl/certs/ca-certificates.crt" >> /etc/wgetrc

echo "Done installing wget"

