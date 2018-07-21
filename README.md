# Masternodescripts
Masternode Install script for Ubuntu VPS. Tested on http://vultr.altcoincash.xyz/ $5 VPS with Ubuntu 16.04.
This script configures a new vps, install dependencies, set up swapfile and cronjobs, and install HTH in path for ease of use.
It also create a logfile of the install in .hthcore folder. Ip:port and private key show at the end for easy copy/paste to control wallet.
Log in to the vps with Putty/MobaXterm, then run following commands

 Help the Homeless coin:

```
wget https://raw.githubusercontent.com/GpuHot/Masternodescripts/master/hth_ubuntu_install.sh
bash hth_ubuntu_install.sh
```
Sit back and wait while the script finishes, or set up the local wallet:
Make a receive address called Masternode1, send collateral 2 500 000 HTH to the address. Wait for confirmations.
Go to Settings > Options >Wallet, and activate "Show Masternodes Tab"
Go to Tools > Debug Console, and enter following: masternode outputs. This returns collateral_output_txid and collateral_output_index
Go to Tools > Open Masternode Configuration File
Make a new line like the example,
Masternode1 ip:port GENKEY collateral_output_txid collateral_output_index

Where the ip:port and GENKEY is retrieved from the finished VPS install. collateral_output_txid AND collateral_output_index is from the Debug console.
Save the file and restart your wallet. Wait until fully synchronized, then go to Masternode tab and start your Masternode.

You can check on the VPS with commands:
```
check: hth-cli masternode status
stop:  hth-cli stop
start: hthd
```
