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
  sudo apt update && sudo apt upgrade -y && sudo apt install lz4
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
  curl -L https://snapshots-testnet.nodejumper.io/0g-testnet/genesis.json > $HOME/.0gchain/config/genesis.json
  curl -L https://snapshots-testnet.nodejumper.io/0g-testnet/addrbook.json > $HOME/.0gchain/config/addrbook.json
  sleep 1
  echo done

  printGreen "7. Добавление seeds, peers, настройка портов, pruning, минимальной цены газа..." && sleep 1
  SEEDS="81987895a11f6689ada254c6b57932ab7ed909b6@54.241.167.190:26656,010fb4de28667725a4fef26cdc7f9452cc34b16d@54.176.175.48:26656,e9b4bc203197b62cc7e6a80a64742e752f4210d5@54.193.250.204:26656,68b9145889e7576b652ca68d985826abd46ad660@18.166.164.232:26656"
  PEERS="82e19f33a6fad853a840fb4cc7c766d8683af9f6@62.171.156.33:12656,df4cc52fa0fcdd5db541a28e4b5a9c6ce1076ade@37.60.246.110:13456,11472bb2b9375d7295072dd7d71020af41d62d9c@62.171.130.10:26656,f452d51556bb089b07206719c6b23976988c23ac@144.91.88.250:12656,09fb910f32578a97e50f8bb924593f8cca15a903@158.220.101.41:12656,b758e014f806ebacba15cc31d469915f85a479ae@45.140.185.42:12656,dbfb5240845c8c7d2865a35e9f361cc42877721f@78.46.40.246:34656,a543e53b7331e2da7475ff84b0d8b4110066cc12@89.116.31.53:12656,5b621f8331f9437aab4f537074e5ccb2bba13b23@149.50.119.163:12656,d5e294d6d5439f5bd63d1422423d7798492e70fd@77.237.232.146:26656,4b887177161c397f403e58e398ad562544773d83@207.180.231.96:26656,1b1e563f432537fa1fac98e2fa3f8313845e79b7@89.116.28.73:12656,219916e6fc45cacddb97e0709756741a6e362d20@149.50.119.199:12656,6edf69fe940a8bec131c3fd63cc17fcef244a663@109.199.112.116:12656,6efd3559f5d9d13e6442bc2fc9b17e50dc800970@91.205.104.91:13456"
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
