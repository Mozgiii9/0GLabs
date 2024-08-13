#!/bin/bash

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

menu() {
  echo "Выберите действие:"
  echo "1. Установить ноду 0G Labs"
  echo "2. Проверить синхронизацию 0G Labs"
  echo "3. Создать кошелек 0G Labs"
  echo "4. Импортировать уже существующий кошелек 0G Labs"
  echo "5. Проверить баланс кошелька"
  echo "6. Создать валидатора 0G Labs"
  echo "7. Просмотреть логи ноды 0G Labs"
  echo "8. Выйти из установочного скрипта"
  read -p "Введите номер действия: " action

  case $action in
    1)
      install_node
      ;;
    2)
      check_sync
      ;;
    3)
      create_wallet
      ;;
    4)
      import_wallet
      ;;
    5)
      check_balance
      ;;
    6)
      create_validator
      ;;
    7)
      view_logs
      ;;
    8)
      exit 0
      ;;
    *)
      echo "Неверный ввод, попробуйте снова."
      menu
      ;;
  esac
}

install_node() {
  read -p "Введите имя кошелька: " WALLET
  echo 'export WALLET='$WALLET
  read -p "Создайте имя для Вашей ноды: " MONIKER
  echo 'export MONIKER='$MONIKER
  read -p "Введите PORT (например, 17, по умолчанию 26): " PORT
  echo 'export PORT='$PORT

  echo "export WALLET=$WALLET" >> $HOME/.bash_profile
  echo "export MONIKER=$MONIKER" >> $HOME/.bash_profile
  echo "export OG_CHAIN_ID=zgtendermint_16600-2" >> $HOME/.bash_profile
  echo "export OG_PORT=$PORT" >> $HOME/.bash_profile
  echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin:$(go env GOPATH)/bin" >> $HOME/.bash_profile
  source $HOME/.bash_profile

  echo "INFORMATION:"
  echo -e "Имя ноды:        \e[1m\e[32m$MONIKER\e[0m"
  echo -e "Имя кошелька:         \e[1m\e[32m$WALLET\e[0m"
  echo -e "Chain ID:       \e[1m\e[32m$OG_CHAIN_ID\e[0m"
  echo -e "Port:  \e[1m\e[32m$OG_PORT\e[0m"
  
  sleep 1

  printGreen "1. Установка go..." && sleep 1
  sudo apt update && sudo apt upgrade -y && sudo apt install lz4 git
  cd $HOME
  VER="1.21.3"
  wget "https://golang.org/dl/go$VER.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "go$VER.linux-amd64.tar.gz"
  rm "go$VER.linux-amd64.tar.gz"
  [ ! -f ~/.bash_profile ] && touch ~/.bash_profile
  echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bash_profile
  source $HOME/.bash_profile
  [ ! -d ~/go/bin ] && mkdir -p ~/go/bin

  echo $(go version) && sleep 1

  source <(curl -s https://raw.githubusercontent.com/itrocket-team/testnet_guides/main/utils/dependencies_install)

  printGreen "4. Установка бинарных файлов..." && sleep 1
  cd $HOME
  rm -rf 0g-chain
  git clone https://github.com/0glabs/0g-chain.git
  cd 0g-chain
  git checkout v0.3.1.alpha.1
  make install

  printGreen "5. Настройка и инициализация приложения..." && sleep 1
  0gchaind config node tcp://localhost:${OG_PORT}657
  0gchaind config keyring-backend os
  0gchaind config chain-id zgtendermint_16600-2
  0gchaind init $MONIKER --chain-id zgtendermint_16600-2
  sleep 1
  echo done

  printGreen "6. Загрузка генезиса и addrbook..." && sleep 1
  curl -L https://snapshots-testnet.nodejumper.io/0g-testnet/genesis.json > $HOME/.0gchain/config/genesis.json
  curl -L https://snapshots-testnet.nodejumper.io/0g-testnet/addrbook.json > $HOME/.0gchain/config/addrbook.json
  sleep 1
  echo done

  printGreen "7. Добавление seeds, peers, настройка портов, pruning, минимальной цены газа..." && sleep 1
  SEEDS="81987895a11f6689ada254c6b57932ab7ed909b6@54.241.167.190:26656,010fb4de28667725a4fef26cdc7f9452cc34b16d@54.176.175.48:26656,e9b4bc203197b62cc7e6a80a64742e752f4210d5@54.193.250.204:26656,68b9145889e7576b652ca68d985826abd46ad660@18.166.164.232:26656"
  PEERS="e396f55133cb93ff2f2333f379fe9ad76074e005@136.243.9.249:24556,e371f26305869fd8294f6e57dc01ffbbd394a5ac@156.67.80.182:26656,ffa3714c696cda448e9174b29eb98c9b6d45ba00@156.67.81.113:12656,399329896764fce054d96d74e761dc01f408803d@161.97.78.6:26656,7da685b1aca1f88dd36f152d2107fc462eceaa83@194.163.146.132:13456,3ceb228c6f031b7a68cf7c6ebe7e317b542587c9@62.171.183.248:12656,8af551c4554639f52097d096bdbc59ab9e0c2b19@38.242.238.22:12656,ad189adc600e7b8a472560bed60b356701b1736f@176.105.85.3:12656,c68a84b468bcfd48132933939477048badbddad7@148.113.17.55:21156,e2572fec2675e92a2c16572d0e59df4faac079ee@38.242.151.106:12656,4831925b70074e630a896156adfb37779f04eceb@65.109.30.35:56656,302adfd4a043d6494b8262dab846efcee6f0e6ba@185.250.37.5:26656,f89eefd1b00754ae2c6033f5cc60eeb0d6bf62a9@212.90.120.230:12656,3a4612bab7aafd6f57ff857bf83a0fb447a47a75@65.21.114.39:56656,7baa9325f18259079d701d649d22221232dd7a8d@116.202.51.84:26656"
  sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.0gchain/config/config.toml

  sed -i.bak -e "s%:1317%:${OG_PORT}317%g;
  s%:8080%:${OG_PORT}080%g;
  s%:9090%:${OG_PORT}090%g;
  s%:9091%:${OG_PORT}091%g;
  s%:8545%:${OG_PORT}545%g;
  s%:8546%:${OG_PORT}546%g;
  s%:6065%:${OG_PORT}065%g" $HOME/.0gchain/config/app.toml

  sed -i.bak -e "s%:26658%:${OG_PORT}658%g;
  s%:26657%:${OG_PORT}657%g;
  s%:6060%:${OG_PORT}060%g;
  s%:26656%:${OG_PORT}656%g;
  s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${OG_PORT}656\"%;
  s%:26660%:${OG_PORT}660%g" $HOME/.0gchain/config/config.toml

  sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.0gchain/config/app.toml
  sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.0gchain/config/app.toml
  sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"50\"/" $HOME/.0gchain/config/app.toml

  sed -i 's|minimum-gas-prices =.*|minimum-gas-prices = "0ua0gi"|g' $HOME/.0gchain/config/app.toml
  sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.0gchain/config/config.toml
  sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.0gchain/config/config.toml
  sleep 1
  echo done

  sudo tee /etc/systemd/system/0gchaind.service > /dev/null <<EOF
[Unit]
Description=og node
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/.0gchain
ExecStart=$(which 0gchaind) start --home $HOME/.0gchain
Restart=on-failure
RestartSec=5
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

  printGreen "8. Загрузка снепшота и запуск ноды..." && sleep 1
  0gchaind tendermint unsafe-reset-all --home $HOME/.0gchain
  if curl -s --head curl https://snapshots-testnet.nodejumper.io/0g-testnet/0g-testnet_latest.tar.lz4 | head -n 1 | grep "200" > /dev/null; then
    curl https://snapshots-testnet.nodejumper.io/0g-testnet/0g-testnet_latest.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.0gchain
  else
    echo нет снепшота
  fi

  sudo systemctl daemon-reload
  sudo systemctl enable 0gchaind
  sudo systemctl restart 0gchaind

  # Проверяем статус сервиса
  if systemctl is-active --quiet 0gchaind; then
    echo "Сервис 0gchaind успешно запущен."
  else
    echo "Ошибка: сервис 0gchaind не запущен. Проверяем логи..."
    sudo journalctl -u 0gchaind --no-pager | tail -n 20
  fi
  
  export GOPATH=$HOME/go
  export GOBIN=$GOPATH/bin
  export PATH=$PATH:$GOPATH/bin:$GOROOT/bin
  echo "Установка завершена. Возвращение в меню..."
  menu
}

check_sync() {
  STATUS=$(0gchaind status 2>&1)
  if echo "$STATUS" | jq . >/dev/null 2>&1; then
    echo "$STATUS" | jq
  else
    echo "Ошибка: вывод команды не является корректным JSON"
    echo "$STATUS"
  fi
  menu
}

create_wallet() {
  0gchaind keys add $WALLET

  WALLET_ADDRESS=$(0gchaind keys show $WALLET -a)
  VALOPER_ADDRESS=$(0gchaind keys show $WALLET --bech val -a)
  echo "export WALLET_ADDRESS=$WALLET_ADDRESS" >> $HOME/.bash_profile
  echo "export VALOPER_ADDRESS=$VALOPER_ADDRESS" >> $HOME/.bash_profile
  source $HOME/.bash_profile

  0gchaind debug addr $(0gchaind keys show $WALLET_ADDRESS -a) | grep 'Address (hex):' | awk -F ': ' '{print "0x" $2}'

  echo "Кошелек создан. Возвращение в меню..."
  menu
}

import_wallet() {
  read -p "Введите имя кошелька: " WALLET
  0gchaind keys add $WALLET --recover

  WALLET_ADDRESS=$(0gchaind keys show $WALLET -a)
  VALOPER_ADDRESS=$(0gchaind keys show $WALLET --bech val -a)
  echo "export WALLET_ADDRESS=$WALLET_ADDRESS" >> $HOME/.bash_profile
  echo "export VALOPER_ADDRESS=$VALOPER_ADDRESS" >> $HOME/.bash_profile
  source $HOME/.bash_profile

  0gchaind debug addr $(0gchaind keys show $WALLET_ADDRESS -a) | grep 'Address (hex):' | awk -F ': ' '{print "0x" $2}'

  echo "Кошелек импортирован. Возвращение в меню..."
  menu
}

create_validator() {
  read -p "Ранее Вы уже создавали валидатора 0G Labs? [да/нет]: " response
  if [[ "$response" == "да" || "$response" == "Да" ]]; then
    0gchaind tx staking edit-validator \
    --commission-rate 0.1 \
    --new-moniker "$MONIKER" \
    --identity "" \
    --details "" \
    --from $WALLET \
    --chain-id zgtendermint_16600-2 \
    --gas=auto --gas-adjustment=1.6 \
    -y
  else
    0gchaind tx staking create-validator \
    --amount 1000000ua0gi \
    --from $WALLET \
    --commission-rate 0.1 \
    --commission-max-rate 0.2 \
    --commission-max-change-rate 0.01 \
    --min-self-delegation 1 \
    --pubkey $(0gchaind tendermint show-validator) \
    --moniker "$MONIKER" \
    --identity "" \
    --details "ZeroGravityNode" \
    --chain-id zgtendermint_16600-2 \
    --gas=auto --gas-adjustment=1.6 \
    -y 
  fi

  echo "Операция выполнена. Возвращение в меню..."
  menu
}

view_logs() {
  echo "Через 15 секунд начнется отображение логов ноды 0G Labs. Для возвращения в меню нажмите CTRL+C"
  sleep 15
  sudo journalctl -u 0gchaind -f
}

check_balance() {
  0gchaind q bank balances $WALLET_ADDRESS
  echo "Возвращение в меню..."
  menu
}

menu
