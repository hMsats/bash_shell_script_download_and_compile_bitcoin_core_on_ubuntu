#!/bin/bash

#
# Bash script to compile Bitcoin Core on Ubuntu Linux.
#
# You'll find bitcoind and bitcoin-cli in $HOME/bitcoin-23.0/src and
# bitcoin-qt in $HOME/bitcoin-23.0/src/qt when compiling version 23.0
#
# Usage:
# ./maken.sh 23.0
# to download and compile bitcoin version 23.0
#

# Set the "do"-variables to 1 or 0 to execute or
# not execute a specific part of the code
# All are 1 by default
do_download_and_unpack_bitcoin_core=1 # Download and unpack bitcoin core from bitcoincore.org
do_check_bitcoin_core_download=1 # Set to 0 if compiling versions < 22.0
do_install_packages=1 # Download the packages needed to compile bitcoin core
do_download_berkeley_db=1 # Download berkeley db needed to compile bitcoin core
do_compile_berkeley_db=1 # Compile berkeley db needed to compile bitcoin core
do_compile_bitwoin_core=1 # Compile Bitcoin Core
do_test_bitcoin_core=1 # Test Bitcoin Core

# Echo with sleep and newlines
function fecho () {
  sleep 5
  echo ""
  echo $1
  echo ""
  sleep 5
}
# Abort if directory exists
function dexab () {
  if [[ -d "$1" ]]; then
    echo "$1 already exists in your home directory"
    echo "Aborting this Bash script"
    exit
  fi
}
# Abort if file exists
function fexab () {
  if [[ -f "$1" ]]; then
    echo "$1 already exists in your home directory"
    echo "Aborting this Bash script"
    exit
  fi
}
# Abort if directory does not exist
function dnexab () {
  if [[ ! -d "$1" ]]; then
    echo "$1 doesn't exist in your home directory"
    echo "Aborting this Bash script"
    exit
  fi
}
# Abort if file doesn't exist
function fnexab () {
  if [[ ! -f "$1" ]]; then
    echo "$1 dowsn't exist in your home directory"
    echo "Aborting this Bash script"
    exit
  fi
}

# Demand 1 and only 1 command line option
if [ $# != 1 ]; then
  echo "Usage:"
  echo "  ./maken.sh version"
  echo "Example:"
  echo "  ./maken.sh 23.0"
  echo "EXIT"
  exit
fi

VERSION=$1
BITCOIN_NAME=bitcoin-$VERSION

# Move to the home directory
cd $HOME

# 
# DOWNLOAD AND UNPACK BITCOIN CORE
#

if [ $do_download_and_unpack_bitcoin_core = 1 ]; then

  echo "Downloading $HOME/bitcoin-$VERSION.tar.gz in $HOME from bitcoincore.org"
  fexab $HOME/bitcoin-$VERSION.tar.gz
  \wget --quiet -O bitcoin-$VERSION.tar.gz https://bitcoincore.org/bin/bitcoin-core-$VERSION/bitcoin-$VERSION.tar.gz
  
  if [ $do_check_bitcoin_core_download = 1 ]; then
    fecho "Checking the bitcoin core download"
    fexab SHA256SUMS
    \wget --quiet -O SHA256SUMS https://bitcoincore.org/bin/bitcoin-core-$VERSION/SHA256SUMS
    fnexab SHA256SUMS
    fexab SHA256SUMS.asc
    \wget --quiet -O SHA256SUMS.asc https://bitcoincore.org/bin/bitcoin-core-$VERSION/SHA256SUMS.asc
    fnexab SHA256SUMS.asc
    res0=$(sha256sum --ignore-missing --check SHA256SUMS bitcoin-$VERSION.tar.gz | sed "s/bitcoin-$VERSION.tar.gz: //")
    if [[ -z "$res0" || $res0 != "OK" ]]; then
      echo "Download of bitcoin-$VERSION.tar.gz has the wrong sha256 checksum"
      echo "Aborting this Bash script"
      # Don't leave traces. Avoid that we run into troubles when downloading the next version
      \rm SHA256SUMS
      \rm SHA256SUMS.asc
      exit
    else
      fecho "Download of bitcoin core OK"
    fi
    # Don't leave traces. Avoid that we run into troubles when downloading the next version
    \rm SHA256SUMS
    \rm SHA256SUMS.asc
  else
    fecho "Skip checking the bitcoin core download"
  fi

  fecho "Unpacking $HOME/bitcoin-$VERSION.tar.gz in $HOME"
  dexab $HOME/bitcoin-$VERSION
  \tar -zxf bitcoin-$VERSION.tar.gz

else
  echo "Skip downloading and unpacking bitcoin core"
fi

#
# INSTALL REQUIRED PACKAGES
#

if [ $do_install_packages = 1 ]; then
  fecho "Installing packages via sudo (password probably needed)"

  # Install doxygen
  # Adding repository universe is necessary for 20.04.1 LTS
  # but will be skipped if already present
  sudo apt-add-repository universe
  sudo apt-get update
  sudo apt-get install doxygen

  # Install other packages
  sudo apt-get install make libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler libboost-all-dev build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils python3
else
  fecho "Skip installing packages"
fi

#
# COMPILE BERKELEY-DB
#

if [ $do_compile_berkeley_db = 1 ]; then
  cd $HOME
  if [ $do_download_berkeley_db = 1 ]; then
    fecho "Downloading berkeley-db"
    fexab db-4.8.30.NC.tar.gz
    \wget http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz
 
    # Check the sha256 checksum of the berkeley-db download
    res=$(echo '12edc0df75bf9abd7f82f821795bcee50f42cb2e5f76a6a281b85732798364ef  db-4.8.30.NC.tar.gz' | sha256sum -c | sed 's/db-4.8.30.NC.tar.gz: //')
    if [[ -z "$res" || $res != "OK" ]]; then
      echo "Download of berkeley-db has the wrong sha256 checksum"
      echo "Aborting this Bash script"
      exit
    fi
    
    fecho "Unpacking berkeley-db"
    dexab db-4.8.30.NC
    \tar -zxf db-4.8.30.NC.tar.gz
  else
    fecho "Skip downloading berkeley-db"
  fi
  fecho "Compiling berkeley-db"

  # This error needs to be corrected, see:
  # https://www.fsanmartin.co/compiling-berkeley-db-4-8-30-in-ubuntu-19/
  dnexab db-4.8.30.NC
  cd db-4.8.30.NC
  \mv dbinc/atomic.h dbinc/atomic.h_orig
  cat dbinc/atomic.h_orig | sed 's/__atomic_compare_exchange/__atomic_compare_exchange_db/' > dbinc/atomic.h

  cd build_unix
  mkdir -p build
  BDB_PREFIX="$HOME/db-4.8.30.NC/build_unix/build/"
  echo BDB $BDB_PREFIX
  ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=$BDB_PREFIX
  \make install
else
  fecho "Skip compiling berkeley-db"
fi

#
# COMPILE BITCOIN CORE
#

if [ $do_compile_bitwoin_core = 1 ]; then
  fecho "Compiling Bitcoin Core"
  # Execute in the Bitcoin directory:
  dnexab $HOME/$BITCOIN_NAME
  cd $HOME/$BITCOIN_NAME/

  BDB_PREFIX="$HOME/db-4.8.30.NC/build_unix/build"
  echo BDB $BDB_PREFIX

  fecho "Executing autogen.sh before executing make"
  fnexab ./autogen.sh
  ./autogen.sh

  fecho "Executing configure before executing make"
  fnexab ./configure
  ./configure CPPFLAGS="-I$BDB_PREFIX/include/" LDFLAGS="-L$BDB_PREFIX/lib/" --with-gui

  fecho "Executing make"
  \make # find bitcoind and bitcoin-cli in src, bitcoin-qt in src/qt
else
  fecho "Skip compiling bitcoin core"
fi

#
# TEST BITCOIN CORE
#

if [ $do_test_bitcoin_core = 1 ]; then
  fecho "Testing Bitcoin Core"

  fecho "Testing bitcoind"
  dnexab $HOME/$BITCOIN_NAME/src/test
  cd $HOME/$BITCOIN_NAME/src/test
  ./test_bitcoin

  fecho "Testing bitcoin-qt"
  dnexab $HOME/$BITCOIN_NAME/src/qt/test
  cd $HOME/$BITCOIN_NAME/src/qt/test
  ./test_bitcoin-qt
else
  fecho "Skip testing bitcoin core"
fi
