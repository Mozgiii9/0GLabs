#!/bin/bash

while true; do

  # Логотип
  echo -e '\e[40m\e[32m'
  echo -e '███╗   ██╗ ██████╗ ██████╗ ███████╗██████╗ ██╗   ██╗███╗   ██╗███╗   ██╗███████╗██████╗ '
  echo -e '████╗  ██║██╔═══██╗██╔══██╗██╔════╝██╔══██╗██║   ██║████╗  ██║████╗  ██║██╔════╝██╔══██╗'
  echo -e '██╔██╗ ██║██║   ██║██║  ██║█████╗  ██████╔╝██║   ██║██╔██╗ ██║██╔██╗ ██║█████╗  ██████╔╝'
  echo -e '██║╚██╗██║██║   ██║██║  ██║██╔══╝  ██╔══██╗██║   ██║██║╚██╗██║██║╚██╗██║██╔══╝  ██╔══██╗'
  echo -e '██║ ╚████║╚██████╔╝██████╔╝███████╗██║  ██║╚██████╔╝██║ ╚████║██║ ╚████║███████╗██║  ██║'
  echo -e '╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝'
  echo -e '\e[0m'

  echo -e "\nПодписаться на канал may.crypto{🦅} чтобы быть в курсе самых актуальных нод - https://t.me/maycrypto\n"

  sleep 2

  # Меню
  PS3='Выберите действие: '
  options=(
  "Установить ноду 0G Labs"
  "Создать кошелек"
  "Импортировать уже существующий кошелек"
  "Создать валидатор 0G Labs"
  "Проверить статус синхронизации ноды 0G Labs"
  "Выйти из установочного скрипта")
  
  select opt in "${options[@]}"; do
    case $opt in

    "Установить ноду 0G Labs")
      echo "============================================================"
      echo "Начало установки..."
      echo "============================================================"

      # Установка переменных
      if [ -z "$NODENAME" ]; then
        read -p "Введите имя ноды: " NODENAME
        echo "export NODENAME=$NODENAME" >> "$HOME/.bash_profile"
      fi
      if [ -z "$WALLET" ]; then
        echo "export WALLET=wallet" >> "$HOME/.bash_profile"
      fi
      echo "export OG_CHAIN_ID=zgtendermint_16600-2" >> "$HOME/.bash_profile"
      source "$HOME/.bash_profile"

      # Обновление
      sudo apt update && sudo apt upgrade -y

      # Установка пакетов
      sudo apt install curl iptables build-essential git wget jq make gcc nano tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev -y

      # Установка Go
      sudo rm -rf /usr/local/go
      curl -L https://go.dev/dl/go1.21.6.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
      echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> "$HOME/.bash_profile"
      source "$HOME/.bash_profile"

      # Загрузка бинарников
      cd || exit
      rm -rf 0g-chain
      git clone https://github.com/0glabs/0g-chain
      cd 0g-chain || exit
      git checkout v0.2.3
      make install

      # Конфигурация
      0gchaind config chain-id zgtendermint_16600-2
      0gchaind config keyring-backend test

      # Инициализация
      0gchaind init "$NODENAME" --chain-id "$OG_CHAIN_ID"

      # Загрузка genesis и addrbook
      curl -L https://snapshots-testnet.nodejumper.io/0g-testnet/genesis.json > "$HOME/.0gchain/config/genesis.json"
      curl -L https://snapshots-testnet.nodejumper.io/0g-testnet/addrbook.json > "$HOME/.0gchain/config/addrbook.json"

      # Установка минимальной цены газа
      sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.0025ua0gi\"|" "$HOME/.0gchain/config/app.toml"

      # Установка пиров и сидов
      SEEDS="81987895a11f6689ada254c6b57932ab7ed909b6@54.241.167.190:26656,010fb4de28667725a4fef26cdc7f9452cc34b16d@54.176.175.48:26656,e9b4bc203197b62cc7e6a80a64742e752f4210d5@54.193.250.204:26656,68b9145889e7576b652ca68d985826abd46ad660@18.166.164.232:26656"
      PEERS="b3411cfb89113055dce89277c7cc7029ce451090@195.201.242.107:26656,ed87b92b175a6e42f2688efb4f6070bb57a4914f@89.117.63.18:12656,35e76dcea85061feaef024ede1e1dd8661332238@62.171.132.194:12656,057f64f293f0843c849aa3f1f1e20a1a0add29f8@45.159.222.237:26656,85233db31304a69fb2dda924b5de31c22dfcff5a@45.10.161.188:26656,89e272c0e5007e391f420e4f45e1473f91995025@154.26.155.239:26656,96d615925aee68b90bfaf18d461e799fdcb22211@45.10.162.96:26656,b2ea93761696d4881e87f032a7f6158c6c25d92c@45.14.194.241:26646,cfd099ade96d82908b4ab185eddbf90379579bfc@84.247.149.9:26656,bc8898c416f7b22e56782eb16803150fd90863b6@81.0.221.180:26656,0aa16751b6c1884e755997d08dc17f8582aa9e38@45.10.163.80:26656,364c45b7cab8a095cb59443f3e91fd102ec9eb95@158.220.118.216:26656,7ecfe8d9404a4e1ea36cba5d546650da2b97bfd2@45.90.122.129:26656,c8807bba12fa67676319df8e049ae5fac690cf55@45.159.228.20:26656,d7ca6521ee30f8cf9eaf32e9edee1101e44c48e9@45.10.161.5:26656,369666051d45ed28379db34a80dfdf13e43d3681@5.104.80.63:26656,03619b6f90fab32cd5f0cadbe3021e6a3cda16e3@154.26.156.101:26656,6e3c5aaab9d3ac6c0de9fd90648cdced499086bf@65.109.58.118:12656,3acd788260951058a8013ea8bdcc1119cfacfdf3@144.91.116.21:12656,443a1a6f2859be27b4699ffcb31c62ab69af4ba2@155.133.27.209:12656"
      sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" "$HOME/.0gchain/config/config.toml"

      # Отключение индексирования
      indexer="null"
      sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" "$HOME/.0gchain/config/config.toml"

      # Конфигурация обрезки
      pruning="custom"
      pruning_keep_recent="100"
      pruning_keep_every="0"
      pruning_interval="10"
      sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" "$HOME/.0gchain/config/app.toml"
      sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" "$HOME/.0gchain/config/app.toml"
      sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" "$HOME/.0gchain/config/app.toml"
      sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" "$HOME/.0gchain/config/app.toml"
      sed -i "s/snapshot-interval *=.*/snapshot-interval = 0/g" "$HOME/.0gchain/config/app.toml"

      # Включение Prometheus
      sed -i -e "s/prometheus = false/prometheus = true/" "$HOME/.0gchain/config/config.toml"

      # Создание службы
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

      # Сброс
      0gchaind tendermint unsafe-reset-all --home "$HOME/.0gchain" --keep-addr-book
      curl https://snapshots-testnet.nodejumper.io/0g-testnet/0g-testnet_latest.tar.lz4 | lz4 -dc - | tar -xf - -C "$HOME/.0gchain"

      # Запуск службы
      sudo systemctl daemon-reload
      sudo systemctl enable 0gchaind
      sudo systemctl restart 0gchaind

      break
      ;;

    "Создать кошелек")
      0gchaind keys add "$WALLET"
      echo "============================================================"
      echo "Сохраните адрес и Seed фразу"
      echo "============================================================"
      OG_WALLET_ADDRESS=$(0gchaind keys show "$WALLET" -a)
      OG_VALOPER_ADDRESS=$(0gchaind keys show "$WALLET" --bech val -a)
      echo "export OG_WALLET_ADDRESS=${OG_WALLET_ADDRESS}" >> "$HOME/.bash_profile"
      echo "export OG_VALOPER_ADDRESS=${OG_VALOPER_ADDRESS}" >> "$HOME/.bash_profile"
      source "$HOME/.bash_profile"

      break
      ;;

    "Импортировать уже существующий кошелек")
      echo "============================================================"
      echo "Введите seed фразу от Вашего кошелька 0G Labs"
      echo "============================================================"
      0gchaind keys add "$WALLET" --recover
      OG_WALLET_ADDRESS=$(0gchaind keys show "$WALLET" -a)
      OG_VALOPER_ADDRESS=$(0gchaind keys show "$WALLET" --bech val -a)
      echo "export OG_WALLET_ADDRESS=${OG_WALLET_ADDRESS}" >> "$HOME/.bash_profile"
      echo "export OG_VALOPER_ADDRESS=${OG_VALOPER_ADDRESS}" >> "$HOME/.bash_profile"
      source "$HOME/.bash_profile"

      break
      ;;

    "Создать валидатор 0G Labs")
      0gchaind tx staking create-validator \
      --amount=1000000ua0gi \
      --pubkey=$(0gchaind tendermint show-validator) \
      --moniker="$NODENAME" \
      --chain-id=zgtendermint_16600-2 \
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

    "Проверить статус синхронизации ноды 0G Labs")
      source "$HOME/.bash_profile"
      0gchaind status 2>&1 | jq .SyncInfo

      break
      ;;

    "Выйти из установочного скрипта")
      exit
      ;;
    *) echo "Неверная опция $REPLY";;
    esac
  done
done
