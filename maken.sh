#!/bin/bash

# Simple Bash script to compile Bitcoin Core
# on Ubuntu Linux. 

# You'll find bitcoind and bitcoin-cli in $HOME/bitcoin-$VERSION.0/src 
# and bitcoin-qt in $HOME/bitcoin-$VERSION/src/qt
#

# Set the "do"-variables to 1 or 0 to execute or 
# not execute a specific part of the code 
# All are default 1
do_download_bitcoin_core=1 # Download bitcoin core from bitcoincore.org (download not checked (yet))
do_install_packages=1 # Download the packages needed to compile bitcoin core
do_download_berkeley_db=1 # Download berkeley db needed to compile bitcoin core
do_compile_berkeley_db=1 # Compile berkeley db needed to compile bitcoin core
do_compile_bitwoin_core=1 # Compile Bitcoin Core
do_test_bitcoin_core=1 # Test Bitcoin Core

function fecho () {
  sleep 5
  echo ""
  echo $1
  echo ""
  sleep 5
}

if [ $# == 0 ]; then
  echo "Usage:"
  echo "./maken.sh version"
  echo "Example:"
  echo "./maken.sh 23.0"
  echo "EXIT"
  exit
fi

cd $HOME

VERSION=$1

if [ $do_download_bitcoin_core = 1 ]; then

  if [[ -d "$HOME/bitcoin-$VERSION" ]]; then
    echo "$HOME/bitcoin-$VERSION already exists in your home directory"
    echo "Aborting this Bash script" 
    echo "EXIT"
    exit
  else
    echo "Downloading $HOME/bitcoin-$VERSION.tar.gz in $HOME from bitcoincore.org"
  fi

  cd $HOME
  wget --quiet -O bitcoin-$VERSION.tar.gz https://bitcoincore.org/bin/bitcoin-core-$VERSION/bitcoin-$VERSION.tar.gz

  fecho "Unpacking $HOME/bitcoin-$VERSION.tar.gz in $HOME"
  tar -zxf bitcoin-$VERSION.tar.gz

else
  echo "SKIP downloading bitcoin core"
fi

# Check if bitcoin core exists now
if [[ -d "$HOME/bitcoin-$VERSION" ]]; then

  cd $HOME/bitcoin-$VERSION

else

  fecho "$HOME/bitcoin-$VERSION downloading and unpacking bitcoin core failed"
  echo EXIT
  exit

fi

BITCOIN_NAME=$(basename `pwd`) # Should return the current version.

if [ $do_install_packages = 1 ]; then
  fecho "Installing packages"
  
  # Install doxygen
  sudo apt-add-repository universe
  sudo apt-get update
  sudo apt-get install doxygen
  
  # Install other packages
  sudo apt-get install make libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler libboost-all-dev build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils python3
  sleep 5
fi

if [ $do_compile_berkeley_db = 1 ]; then
  cd $HOME
  if [ $do_download_berkeley_db = 1 ]; then
    fecho "Downloading berkeley-db"
    wget http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz
    echo '12edc0df75bf9abd7f82f821795bcee50f42cb2e5f76a6a281b85732798364ef  db-4.8.30.NC.tar.gz' | sha256sum -c
    tar -zxf db-4.8.30.NC.tar.gz
  fi
  fecho "Compiling berkeley-db"

  # This error needs to be corrected, see:
  # https://www.fsanmartin.co/compiling-berkeley-db-4-8-30-in-ubuntu-19/
  cd db-4.8.30.NC
  mv dbinc/atomic.h dbinc/atomic.h_orig
  cat dbinc/atomic.h_orig | sed 's/__atomic_compare_exchange/__atomic_compare_exchange_db/' > dbinc/atomic.h

  cd build_unix

  mkdir -p build
  BDB_PREFIX="$HOME/db-4.8.30.NC/build_unix/build/"
  echo BDB $BDB_PREFIX
  ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=$BDB_PREFIX
  make install
fi

if [ $do_compile_bitwoin_core = 1 ]; then
  fecho "Compiling Bitcoin Core"
  # Execute in the Bitcoin directory:
  cd $HOME/$BITCOIN_NAME/

  BDB_PREFIX="$HOME/db-4.8.30.NC/build_unix/build"
  echo BDB $BDB_PREFIX

  fecho "Executing autogen.sh before executing make"
  ./autogen.sh

  fecho "Executing configure before executing make"
  ./configure CPPFLAGS="-I$BDB_PREFIX/include/" LDFLAGS="-L$BDB_PREFIX/lib/" --with-gui

  fecho "Executing make"
  make # find bitcoind and bitcoin-cli in src, bitcoin-qt in src/qt 
fi

if [ $do_test_bitcoin_core = 1 ]; then
  fecho "Testing Bitcoin Core"
  
  fecho "Testing bitcoind"
  cd $HOME/$BITCOIN_NAME/src/test
  ./test_bitcoin
  
  fecho "Testing bitcoin-qt"
  cd $HOME/$BITCOIN_NAME/src/qt/test
  ./test_bitcoin-qt
fi
