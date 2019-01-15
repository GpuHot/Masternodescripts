# HTHcoin masternode install script
# Edited by Altcoin Cash
VERSION="1.2.0.0"
NODEPORT='35888'
RPCPORT='9215'
# Useful variables
declare -r DATE_STAMP="$(date +%y-%m-%d-%s)"
declare -r SCRIPT_LOGFILE="/root/log_inst_hth_node_${DATE_STAMP}_out.log"
declare -r SCRIPTPATH=$( cd $(dirname ${BASH_SOURCE[0]}) > /dev/null; pwd -P )
declare -r WANIP=$(dig +short myip.opendns.com @resolver1.opendns.com)
function print_greeting() {
	echo ""
	echo -e "HTH masternode install script\n"
}


function print_info() {
	echo ""
	echo -e "[0;35m HTHcoin version:[0m ${VERSION}"
	echo -e "[0;35m Your masternode ip:[0m ${WANIP}"
	echo -e "[0;35m Masternode port:[0m ${NODEPORT}"
	echo -e "[0;35m RPC port:[0m ${RPCPORT}"
	echo -e "[0;35m Date:[0m ${DATE_STAMP}"
	echo -e "[0;35m Logfile:[0m ${SCRIPT_LOGFILE}"
}


function install_packages() {
	echo ""
	echo "Updating system and install dependencies..."
	add-apt-repository -yu ppa:bitcoin/bitcoin  &>> ${SCRIPT_LOGFILE}
	apt-get -y update &>> ${SCRIPT_LOGFILE}
  	apt-get -y upgrade &>> ${SCRIPT_LOGFILE}
	apt-get -y install wget make automake autoconf build-essential libtool autotools-dev \
	git nano python-virtualenv pwgen unzip virtualenv \
	pkg-config libssl-dev libevent-dev bsdmainutils software-properties-common \
	libboost-all-dev libminiupnpc-dev libdb4.8-dev libdb4.8++-dev &>> ${SCRIPT_LOGFILE}
	echo "Install done..."
	echo ""
}


function swaphack() {
	echo "Setting up disk swap..."
	free -h
	rm -f /var/hth_node_swap.img
	rm -f /swapfile
	fallocate -l 4G /swapfile &>> ${SCRIPT_LOGFILE}
	chmod 600 /swapfile
	mkswap /swapfile
	swapon /swapfile
	swapon --show &>> ${SCRIPT_LOGFILE}
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
	free -h
	echo "Swap setup complete..."
	echo ""
}


function remove_old_files() {
	echo "Removing old files..."
	sudo pkill hthd
	sudo rm -rf /root/hth /root/.hthcore /usr/local/bin/hth*
	echo "Done..."
}


function download_wallet() {
	echo "Downloading wallet..."
	wget -q https://github.com/HTHcoin/HTH/releases/download/v1.2/hth-linux.zip
	unzip hth-linux.zip
	rm /root/linux/hth-qt
	chmod +x /root/linux/*
	mv /root/linux/* /usr/local/bin/
	rm -rf /root/linux/
	echo "Done..."
	echo ""
}


function configure_firewall() {
	echo "Configuring firewall rules..."
	apt-get -y install ufw			&>> ${SCRIPT_LOGFILE}
	# disallow everything except ssh and masternode inbound ports
	ufw default deny			&>> ${SCRIPT_LOGFILE}
	ufw logging on				&>> ${SCRIPT_LOGFILE}
	ufw allow ssh/tcp			&>> ${SCRIPT_LOGFILE}
	ufw allow 35888/tcp			&>> ${SCRIPT_LOGFILE}
	ufw allow 9215/tcp			&>> ${SCRIPT_LOGFILE}
	# This will only allow 6 connections every 30 seconds from the same IP address.
	ufw limit OpenSSH			&>> ${SCRIPT_LOGFILE}
	ufw --force enable			&>> ${SCRIPT_LOGFILE}
	echo "Done..."
	echo ""
}


function configure_masternode() {
	echo "Configuring masternode..."
	conffile=/root/.hthcore/hth.conf
	PASSWORD=`pwgen -1 20 -n` &>> ${SCRIPT_LOGFILE}
	if [ "x$PASSWORD" = "x" ]; then
	    PASSWORD=${WANIP}-`date +%s`
	fi
	echo "Loading and syncing wallet..."

	sleep 10
	echo -e "rpcuser=hthuser\nrpcpassword=${PASSWORD}\nrpcport=${RPCPORT}\nrpcallowip=127.0.0.1\nport=${NODEPORT}\nexternalip=${WANIP}\nlisten=1\nmaxconnections=250" >> ${conffile}
	echo ""
	echo -e "[0;35m==================================================================[0m"
	echo -e "     DO NOT CLOSE THIS WINDOW OR TRY TO FINISH THIS PROCESS"
	echo -e "                        PLEASE WAIT..."
	echo -e "[0;35m==================================================================[0m"
	echo ""
	hthd -daemon
	echo "< 2 MINUTES LEFT"
	sleep 30
	echo "< 1 MINUTE LEFT"
	sleep 10
	masternodekey=$(hth-cli masternode genkey)
	hth-cli stop
	echo ""
	sleep 10
	echo "Creating masternode config..."
	echo -e "daemon=1\nmasternode=1\nmasternodeprivkey=$masternodekey" >> ${conffile}
	echo "Done...Starting daemon..."
	hthd -daemon
}

function addnodes() {
	echo "Adding nodes..."
	mkdir /root/.hthcore
	touch /root/.hthcore/hth.conf
	conffile=/root/.hthcore/hth.conf
	echo -e "\addnode=151.236.57.21:35888" >> ${conffile}
	echo -e "addnode=167.99.158.141:35888" >> ${conffile}
	echo -e "addnode=173.176.247.102:35888" >> ${conffile}
	echo -e "addnode=173.199.118.32:35888" >> ${conffile}
	echo -e "addnode=173.212.247.217:35888" >> ${conffile}
	echo -e "addnode=185.28.103.13:35888" >> ${conffile}
	echo -e "addnode=188.166.80.179:35888" >> ${conffile}
	echo -e "addnode=194.67.217.239:35888" >> ${conffile}
	echo -e "addnode=202.39.49.57:35888" >> ${conffile}
	echo -e "addnode=207.148.92.79:35888" >> ${conffile}
	echo -e "addnode=209.250.248.38:35888" >> ${conffile}
	echo -e "addnode=23.227.163.148:35888" >> ${conffile}
	echo -e "addnode=45.32.190.193:35888" >> ${conffile}
	echo -e "addnode=45.76.254.107:35888" >> ${conffile}
	echo -e "addnode=45.77.186.177:35888" >> ${conffile}
	echo -e "addnode=5.188.104.245:35888" >> ${conffile}
	echo -e "addnode=5.19.171.173:35888" >> ${conffile}
	echo -e "addnode=52.14.3.157:35888" >> ${conffile}
	echo -e "addnode=63.142.254.44:35888\n" >> ${conffile}
	echo "Done..."
}


function show_result() {
	echo ""
	echo -e "[0;35m==================================================================[0m"
	echo "[0;35m Congrats, your masternode is installed and running on the server! [0m"
	echo "DATE: ${DATE_STAMP}"
	echo "LOG: ${SCRIPT_LOGFILE}"
	echo "rpcuser=hthuser"
	echo "rpcpassword=${PASSWORD}"
	echo ""
	echo -e "[0;35m INSTALLED WITH VPS IP: ${WANIP}:${NODEPORT} [0m"
	echo -e "[0;35m INSTALLED WITH MASTERNODE PRIVATE GENKEY: ${masternodekey} [0m"
	echo ""
	echo "Below is alias IP:port masternodeprivkey "
	echo ""
	echo " Copy to local Masternode.conf:[0;35m MN1 ${WANIP}:${NODEPORT} ${masternodekey} [0m "
	echo ""
	echo "In your local wallets debug console, type command: [0;35mmasternode outputs[0m "
	echo "and append resulting collateral_output_txid collateral_output_index to the end of line"
	echo ""
	echo -e "[0;35m==================================================================[0m"
	echo -e "[0;35mCheck your node with command: hth-cli masternode status[0m"
	echo -e "[0;35mStop your node with command: hth-cli stop[0m"
	echo -e "[0;35mStart your node with command: hthd[0m"
	echo -e "[0;35m==================================================================[0m"
	echo -e "If you get \"Masternode not in masternode list\" status, don't worry,\nyou just have to start your MN from your local wallet and the status will change"
	
}


function cleanup() {
	echo "Cleanup..."
	apt-get -y autoremove 	&>> ${SCRIPT_LOGFILE}
	apt-get -y autoclean 		&>> ${SCRIPT_LOGFILE}
}


#Setting auto start cron job for hthd
cronjob="@reboot sleep 30 && hthd"
crontab -l > tempcron
if ! grep -q "$cronjob" tempcron; then
    echo -e "Configuring crontab job..."
    echo $cronjob >> tempcron
    crontab tempcron
fi
rm tempcron


# Flags
compile=0;
swap=0;
firewall=0;


#Bad arguments
if [ $? -ne 0 ];
then
    exit 1
fi


# Check arguments
while [ "$1" != "" ]; do
    case $1 in
        -sw | --swap )
            swap=1
            ;;
        -f | --firewall )
            firewall=1
            ;;
        -n | --addnodes )
            addnodes=1
            ;;
        * )
            exit 1
    esac
    if [ "$#" -gt 0 ]; then shift; fi
done


# main routine
print_greeting
print_info
swaphack
install_packages

if [ "$firewall" -eq 1 ]; then
	configure_firewall
fi

remove_old_files
download_wallet
addnodes
configure_masternode

show_result
cleanup
echo "All done!"
echo -e "Please join our community at HTH Discord https://discord.gg/eUKyUbB"
echo "Ann: https://bitcointalk.org/index.php?topic=4578705"
echo "Twitter: https://twitter.com/hthcoin"
echo "Reddit: https://www.reddit.com/user/HTHCoin"
echo "Facebook: https://www.facebook.com/hth.coin.9"
echo ""
cd ~/
sudo rm /root/hth_ubuntu_install.sh
