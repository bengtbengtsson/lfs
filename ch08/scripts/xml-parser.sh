#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting XML::Parser"
tar -xf XML-Parser-2.47.tar.gz
cd XML-Parser-2.47

echo "### Preparing XML::Parser with Perl"
perl Makefile.PL

echo "### Building XML::Parser"
make

echo "### Running XML::Parser test suite"
make test

echo "### Installing XML::Parser"
make install

cd ..
rm -rf XML-Parser-2.47
popd
