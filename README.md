# A Bash shell script to download and compile Bitcoin Core on Ubuntu

**Example for Bitcoin Core version 23.0:**

Just execute in a terminal `./maken.sh 23.0`

to download and compile bitcoin core version 23.0 in your home directory on Ubuntu Linux.

You'll find bitcoind and bitcoin-cli in bitcoin-23.0/src and bitcoin-qt in bitcoin-23.0/src/qt.

Don't forget `chmod +x maken.sh` before execution. All Bitcoin Core tests are run.

The necessary packages are installed and the appropriate berkeley-db is downloaded and compiled.

Bitcoin Core is downloaded from https://bitcoincore.org.

Total compilation time will be on the order of 1 hour or more.

This script was recently tested on a fairly fresh Ubuntu install (20.04.4 LTS).

Because of how the checksums are calculated, the script "maken.sh" only works for Bitcoin Core versions 22.0 and higher. 
To compile earlier versions set "do_check_bitcoin_core_download=0" inside the script "maken.sh".


If unfamiliar with GithHub, type or past the following in a terminal (ctrl alt t)

```
cd

git clone https://github.com/hMsats/bash_shell_script_download_and_compile_bitcoin_core_on_ubuntu.git

cd bash_shell_script_download_and_compile_bitcoin_core_on_ubuntu

chmod +x maken.sh

./maken.sh 23.0
```

This should install Bitcoin Core 23.0 on your Ubuntu Linux
