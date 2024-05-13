#!/bin/bash

while true
do

# Logo

echo -e '\e[40m\e[92m'
echo -e '███╗   ██╗ ██████╗ ██████╗ ███████╗██████╗ ██╗   ██╗███╗   ██╗███╗   ██╗███████╗██████╗'
echo -e '████╗  ██║██╔═══██╗██╔══██╗██╔════╝██╔══██╗██║   ██║████╗  ██║████╗  ██║██╔════╝██╔══██╗'
echo -e '██╔██╗ ██║██║   ██║██║  ██║█████╗  ██████╔╝██║   ██║██╔██╗ ██║██╔██╗ ██║█████╗  ██████╔╝'
echo -e '██║╚██╗██║██║   ██║██║  ██║██╔══╝  ██╔══██╗██║   ██║██║╚██╗██║██║╚██╗██║██╔══╝  ██╔══██╗'
echo -e '██║ ╚████║╚██████╔╝██████╔╝███████╗██║  ██║╚██████╔╝██║ ╚████║██║ ╚████║███████╗██║  ██║'
echo -e '╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝'
echo -e '\e[0m'

# Menu

PS3='Select an action: '
options=(
"Install"
"Create Wallet"
"Create Validator"
"Exit")
select opt in "${options[@]}"
do
case $opt in

"Install")
echo "============================================================"
echo "Install start"
echo "============================================================"

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export OG_CHAIN_ID=zgtendermint_16600-1" >> $HOME/.bash_profile
source $HOME/.bash_profile

# update
sudo apt update && sudo apt upgrade -y

# packages
apt install curl iptables build-essential git wget jq make gcc nano tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev -y

# install go
if ! [ -x "$(command -v go)" ]; then
ver="1.21.3" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile && \
source $HOME/.bash_profile
fi

# download binary
cd && rm -rf 0g-chain
git clone https://github.com/0glabs/0g-chain
cd 0g-chain
git checkout v0.1.0
make install

# config
0gchaind config chain-id zgtendermint_16600-1
0gchaind config keyring-backend test

# init
0gchaind init $NODENAME --chain-id $OG_CHAIN_ID

# download genesis and addrbook
curl -L https://snapshots-testnet.nodejumper.io/0g-testnet/genesis.json > $HOME/.0gchain/config/genesis.json
curl -L https://snapshots-testnet.nodejumper.io/0g-testnet/addrbook.json > $HOME/.0gchain/config/addrbook.json

# set minimum gas price
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.0025ua0gi\"|" $HOME/.0gchain/config/app.toml

# set peers and seeds
SEEDS="c4d619f6088cb0b24b4ab43a0510bf9251ab5d7f@54.241.167.190:26656,44d11d4ba92a01b520923f51632d2450984d5886@54.176.175.48:26656,f2693dd86766b5bf8fd6ab87e2e970d564d20aff@54.193.250.204:26656"
PEERS="b44ff9e9eb4792bc233147dbe43f1709ad77ce43@80.65.211.223:26656,255360200854a97c65d8c1f2d7154c5dd5e54eb5@65.108.68.214:14256,feb0cc40a3009a16a62bb843c000974565107c4c@128.140.65.68:26656,b2dcd3248fc4104b37568d98495466b4a2074672@65.109.145.247:1020,d10481fc8b787deea4cb789b5aecf16ec81ab076@62.169.26.91:26656,40fe6ab4133d5047b53598af69dc06482f702508@156.67.29.91:26656,258861e4032177e6f0328aa7e2e38b0298510d6c@84.247.188.240:26656,f3c912cf5653e51ee94aaad0589a3d176d31a19d@157.90.0.102:31656,535ddcc917ab5ee6ddd2259875dac6018651da24@176.9.183.45:32656,82791110b18222f5ce1f43792ba1d22e65a706fe@217.28.221.162:26656,6b72d01e9d09d00beac1a004281cfc10833019fe@38.242.138.151:26656,59fe20be127ea2431fcf004af16f101a62269b93@38.242.144.121:26656,cb7b2a0d3de3b6c2d94cdee588176182911cd701@62.169.25.134:26656,e8cd3d7547bdc90cdb275416cce786eefcc754a4@80.71.227.137:26656,0a0b54852a271923277b03366a1f0a1dacbcd464@109.199.102.47:26656,38ae510d30cb048caf99cf87108ec21317a4063f@82.67.49.126:26656,710f94642675d82190d43d272a77dfeb1daaf940@5.9.61.237:19656,9a6a47bd79b3a1bdb27b8df0e6f2218968d56f67@158.220.88.106:26656,645531eb02b275a59cc3b1af99e541852849f695@84.247.139.25:16656,a25dadd5cb8feb5ad88ea39ededce5e81f90c87b@5.75.253.119:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.0gchain/config/config.toml

# disable indexing
indexer="null"
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.0gchain/config/config.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.0gchain/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.0gchain/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.0gchain/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.0gchain/config/app.toml
sed -i "s/snapshot-interval *=.*/snapshot-interval = 0/g" $HOME/.0gchain/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.0gchain/config/config.toml

# create service
sudo tee /etc/systemd/system/0gchaind.service > /dev/null << EOF
[Unit]
Description=0G node service
After=network-online.target
[Service]
User=$USER
ExecStart=$(which 0gchaind) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

# reset
0gchaind tendermint unsafe-reset-all --home $HOME/.0gchain --keep-addr-book
curl https://snapshots-testnet.nodejumper.io/0g-testnet/0g-testnet_latest.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.0gchain

# start service
sudo systemctl daemon-reload
sudo systemctl enable 0gchaind
sudo systemctl restart 0gchaind

break
;;

"Create Wallet")
0gchaind keys add $WALLET
echo "============================================================"
echo "Save address and mnemonic"
echo "============================================================"
OG_WALLET_ADDRESS=$(0gchaind keys show $WALLET -a)
OG_VALOPER_ADDRESS=$(0gchaind keys show $WALLET --bech val -a)
echo 'export OG_WALLET_ADDRESS='${OG_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export OG_VALOPER_ADDRESS='${OG_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile

break
;;

"Create Validator")
0gchaind tx staking create-validator \
--amount=1000000ua0gi \
--pubkey=$(0gchaind tendermint show-validator) \
--moniker=$NODENAME \
--chain-id=zgtendermint_16600-1 \
--commission-rate=0.10 \
--commission-max-rate=0.20 \
--commission-max-change-rate=0.01 \
--min-self-delegation=1 \
--from=wallet \
--gas-prices=0.0025ua0gi \
--gas-adjustment=1.5 \
--gas=300000 \
-y 
  
break
;;

"Exit")
exit
;;
*) echo "invalid option $REPLY";;
esac
done
done
