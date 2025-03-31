#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting perl"
tar -xf perl-5.40.1.tar.xz
cd perl-5.40.1

echo "### Setting environment to use system zlib and bzip2"
export BUILD_ZLIB=False
export BUILD_BZIP2=0

echo "### Configuring perl"
sh Configure -des                                          \
             -D prefix=/usr                                \
             -D vendorprefix=/usr                          \
             -D privlib=/usr/lib/perl5/5.40/core_perl      \
             -D archlib=/usr/lib/perl5/5.40/core_perl      \
             -D sitelib=/usr/lib/perl5/5.40/site_perl      \
             -D sitearch=/usr/lib/perl5/5.40/site_perl     \
             -D vendorlib=/usr/lib/perl5/5.40/vendor_perl  \
             -D vendorarch=/usr/lib/perl5/5.40/vendor_perl \
             -D man1dir=/usr/share/man/man1                \
             -D man3dir=/usr/share/man/man3                \
             -D pager="/usr/bin/less -isR"                 \
             -D useshrplib                                 \
             -D usethreads

echo "### Building perl"
make

echo "### Running perl test suite"
TEST_JOBS=$(nproc) make test_harness

echo "### Installing perl"
make install

echo "### Cleaning up environment"
unset BUILD_ZLIB BUILD_BZIP2

cd ..
rm -rf perl-5.40.1
popd
