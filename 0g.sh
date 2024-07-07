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
  echo "5. Создать валидатора 0G Labs"
  echo "6. Просмотреть логи ноды 0G Labs"
  echo "7. Проверить баланс кошелька"
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
      create_validator
      ;;
    6)
      view_logs
      ;;
    7)
      check_balance
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
  read -p "Введите ваш MONIKER: " MONIKER
  echo 'export MONIKER='$MONIKER
  read -p "Введите ваш PORT (например, 17, по умолчанию 26): " PORT
  echo 'export PORT='$PORT

  echo "export WALLET=$WALLET" >> $HOME/.bash_profile
  echo "export MONIKER=$MONIKER" >> $HOME/.bash_profile
  echo "export OG_CHAIN_ID=zgtendermint_16600-2" >> $HOME/.bash_profile
  echo "export OG_PORT=$PORT" >> $HOME/.bash_profile
  echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin:$(go env GOPATH)/bin" >> $HOME/.bash_profile
  source $HOME/.bash_profile

  printLine
  echo -e "Moniker:        \e[1m\e[32m$MONIKER\e[0m"
  echo -e "Wallet:         \e[1m\e[32m$WALLET\e[0m"
  echo -e "Chain id:       \e[1m\e[32m$OG_CHAIN_ID\e[0m"
  echo -e "Node custom port:  \e[1m\e[32m$OG_PORT\e[0m"
  printLine
  sleep 1

  printGreen "1. Установка go..." && sleep 1
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
  git clone -b v0.2.3 https://github.com/0glabs/0g-chain.git
  cd 0g-chain
  make install

  printGreen "5. Настройка и инициализация приложения..." && sleep 1
  0gchaind config node tcp://localhost:${OG_PORT}657
  0gchaind config keyring-backend os
  0gchaind config chain-id zgtendermint_16600-2
  0gchaind init $MONIKER --chain-id zgtendermint_16600-2
  sleep 1
  echo done

  printGreen "6. Загрузка генезиса и addrbook..." && sleep 1
  wget -O $HOME/.0gchain/config/genesis.json https://testnet-files.itrocket.net/og/genesis.json
  wget -O $HOME/.0gchain/config/addrbook.json https://testnet-files.itrocket.net/og/addrbook.json
  sleep 1
  echo done

  printGreen "7. Добавление seeds, peers, настройка портов, pruning, минимальной цены газа..." && sleep 1
  SEEDS="8f21742ea5487da6e0697ba7d7b36961d3599567@og-testnet-seed.itrocket.net:47656"
  PEERS="c76473c97fa718d1c4c48910c17318883300a36b@og-testnet-peer.itrocket.net:11656"
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
  if curl -s --head curl https://testnet-files.itrocket.net/og/snap_og.tar.lz4 | head -n 1 | grep "200" > /dev/null; then
    curl https://testnet-files.itrocket.net/og/snap_og.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.0gchain
  else
    echo нет снепшота
  fi

  sudo systemctl daemon-reload
  sudo systemctl enable 0gchaind
  sudo systemctl restart 0gchaind
  echo "Установка завершена. Возвращение в меню..."
  menu
}

check_sync() {
  0gchaind status 2>&1 | jq
  echo "Возвращение в меню..."
  menu
}

create_wallet() {
  read -p "Введите имя кошелька: " WALLET
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
    --details "" \
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
