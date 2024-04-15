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

sleep 2

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
echo "export OG_CHAIN_ID=zgtendermint_9000-1" >> $HOME/.bash_profile
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
cd && rm -rf 0g-evmos
git clone https://github.com/0glabs/0g-evmos
cd 0g-evmos
git checkout v1.0.0-testnet
make install

# config
evmosd config chain-id $NIBIRU_CHAIN_ID
evmosd config keyring-backend test

# init
evmosd init $NODENAME --chain-id $NIBIRU_CHAIN_ID

# download genesis and addrbook
curl -L https://snapshots-testnet.nodejumper.io/0g-testnet/genesis.json > $HOME/.evmosd/config/genesis.json
curl -L https://snapshots-testnet.nodejumper.io/0g-testnet/addrbook.json > $HOME/.evmosd/config/addrbook.json

# set minimum gas price
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"250000000aevmos\"|" $HOME/.evmosd/config/app.toml

# set peers and seeds
SEEDS="8c01665f88896bca44e8902a30e4278bed08033f@54.241.167.190:26656,b288e8b37f4b0dbd9a03e8ce926cd9c801aacf27@54.176.175.48:26656,8e20e8e88d504e67c7a3a58c2ea31d965aa2a890@54.193.250.204:26656"
PEERS=""
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.evmosd/config/config.toml

# disable indexing
indexer="null"
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.evmosd/config/config.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.evmosd/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.evmosd/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.evmosd/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.evmosd/config/app.toml
sed -i "s/snapshot-interval *=.*/snapshot-interval = 0/g" $HOME/.evmosd/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.evmosd/config/config.toml

# create service
sudo tee /etc/systemd/system/evmosd.service > /dev/null << EOF
[Unit]
Description=0G node service
After=network-online.target
[Service]
User=$USER
ExecStart=$(which evmosd) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

# reset
evmosd tendermint unsafe-reset-all --home $HOME/.evmosd --keep-addr-book
curl https://snapshots-testnet.nodejumper.io/0g-testnet/0g-testnet_latest.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.evmosd

# start service
sudo systemctl daemon-reload
sudo systemctl enable evmosd
sudo systemctl restart evmosd

break
;;

"Create Wallet")
evmosd keys add $WALLET
echo "============================================================"
echo "Save address and mnemonic"
echo "============================================================"
OG_WALLET_ADDRESS=$(evmosd keys show $WALLET -a)
OG_VALOPER_ADDRESS=$(evmosd keys show $WALLET --bech val -a)
echo 'export OG_WALLET_ADDRESS='${OG_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export OG_VALOPER_ADDRESS='${OG_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile

break
;;

"Create Validator")
evmosd tx staking create-validator \
  --amount=10000000000000000aevmos \
  --pubkey=$(evmosd tendermint show-validator) \
  --moniker=$MONIKER \
  --chain-id=$CHAIN_ID \
  --commission-rate=0.05 \
  --commission-max-rate=0.10 \
  --commission-max-change-rate=0.01 \
  --min-self-delegation=1 \
  --from=$WALLET_NAME \
  --identity="" \
  --website="" \
  --details="0G to the moon!" \
  --gas=500000 --gas-prices=99999aevmos \
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
