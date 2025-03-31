#!/bin/bash
set -e

echo "### Entering /sources"
pushd /sources

echo "### Extracting ninja"
tar -xf ninja-1.12.1.tar.gz
cd ninja-1.12.1

echo "### Patching ninja to honor NINJAJOBS env var"
sed -i '/int Guess/a \
  int   j = 0;\
  char* jobs = getenv( "NINJAJOBS" );\
  if ( jobs != NULL ) j = atoi( jobs );\
  if ( j > 0 ) return j;\
' src/ninja.cc

echo "### Building ninja"
python3 configure.py --bootstrap --verbose

echo "### Installing ninja"
install -vm755 ninja /usr/bin/
install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
install -vDm644 misc/zsh-completion  /usr/share/zsh/site-functions/_ninja

cd ..
rm -rf ninja-1.12.1
popd
