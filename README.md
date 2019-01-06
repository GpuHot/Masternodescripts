# Masternodescripts
Masternode Install script for Help the Homeless coin on Ubuntu VPS. 
This script configures a new vps, install dependencies, set up swapfile and cronjobs, and install HTH in path for ease of use.
A logfile of the install is created. Details shown at the end for easy copy/paste to control wallet.

Tested on http://vultr.altcoincash.xyz/ $5 VPS with Ubuntu 16.04, 64bit OS. 
Also tested on https://m.do.co/c/78dfae8fa2d7 Digital Ocean VPS. 

Go to Vultr > Deploy new server you choose location, os, and add Server Hostname & Label. Nothing else needed.

Click on the new servers name to find IP and root password.
At Digital Ocean you create a new droplet.

To connect to your VPS you need https://www.putty.org/, https://mobaxterm.mobatek.net/download.html or another SSH client.

Log in to the vps with Putty/MobaXterm, with username `root`and the password from vultr.
To paste the password in linux you right click in the screen once.
It will not show anything on the screen, so hit enter to log in.

Copy/paste and run following commands:

__To paste into a linux screen you right click in the screen once.__
After the reboot, log in again.

Now when all is ready, install HTH:
```
wget https://github.com/GpuHot/Masternodescripts/raw/patch2final/hth_ubuntu_install.sh
bash hth_ubuntu_install.sh
```

While waiting for the script to finish, you can set up the local wallet:

* Make a receive address called Masternode1
* Send collateral 2 500 000 HTH to the newly made address. Wait for confirmations.
* Go to Settings > Options >Wallet, and activate "Show Masternodes Tab"
* Go to Tools > Debug Console, and enter following: `masternode outputs` 
  This returns `collateral_output_txid` and `collateral_output_index`
* Go to Tools > Open Masternode Configuration File
  The script prints a config line for this file.
  Add the config line like the example in the file, and add the returns from "masternode outputs"
    ```Masternode1 ip:port GENKEY collateral_output_txid collateral_output_index```

Where the ip:port and GENKEY is retrieved from the finished VPS install. `collateral_output_txid` AND `collateral_output_index` is from the Debug console.

Save the file and restart your wallet. Wait until fully synchronized, then go to Masternode tab and start your Masternode.

You can check on the VPS with commands:
```
check: hth-cli masternode status
stop:  hth-cli stop
start: hthd
To see live output on the vps, use command: tail -f ~/.hthcore/debug.log
```
