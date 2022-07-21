# A Bash shell script to download and compile Bitcoin Core on Ubuntu

**Example for bitcoin-23.0:**

Just execute in a terminal

./maken.sh 23.0

to download and compile bitcoin core version 23.0 in your home directory.

All bitcoin core test are run.

You'll find bitcoind and bitcoin-cli in bitcoin-23.0/src and bitcoin-qt in bitcoin-23.0/src/qt.

The necessary packages are installed and berkeley-db is downloaded and compiled.

Bitcoin Core is downloaded from bitcoincore.org (download is not checked (yet))

This script was recently tested on a fairly fresh Ubuntu install and it worked like a charm.
