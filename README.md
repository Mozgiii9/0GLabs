![image](https://github.com/Mozgiii9/0GLabsSetupTheNode/assets/74683169/efd19714-2463-4cbb-8a3c-0e469e92d673)

## Дата создания файла: 11.04.2024

## Обзор проекта:
[0G Labs](https://0g.ai/) — это модульная цепочка искусственного интеллекта с масштабируемым программируемым уровнем доступности данных (DA), адаптированным для dapps с искусственным интеллектом. Его модульная технология обеспечивает беспрепятственное взаимодействие между цепочками, обеспечивая безопасность, устраняя фрагментацию и максимизируя возможности подключения. Проект появился на радаре еще около 2-х недель назад после инвестиции в $35M от Tier-1 фондов, а уже сегодня 0G запускают оплачиваемый тестнет. На момент написания гайда установлено порядка ~300 нод, поэтому рекомендую не медлить и приступить к установке. Нода будет оплачиваемая, об этом активно пишут модераторы проекта в Discord. Перед установкой ноды необходимо пройти квесты на Galxe. Давайте подробно рассмотрим инвестиции, а также требования к серверу:

![image](https://github.com/Mozgiii9/0GLabsSetupTheNode/assets/74683169/84156744-897b-43e0-a189-d66b1c3cd20b)

**Инвестировали: $35 000 000 (Hack VC, Delphi Digital, Animoca Brands, OKX и другие)**

**Характеристики сервера(рекомендованные):**


**CPU: 4 cores;**

**RAM: 8 GB;**

**Storage: 500 GB SSD;**

**OS: Ubuntu 20.04**

Сервер с такой конфигурацией можно удобно отыскать здесь: [САЙТ](https://ru.hostings.info/hostings/filter_page#vps)

Официальные ресурсы проекта:

- **Веб-сайт:** [перейти](https://0g.ai/)
- **Discord:** [перейти](https://discord.com/invite/0glabs)
- **Twitter:** [перейти](https://twitter.com/0G_labs)
- **Telegram:** [перейти](https://t.me/web3_0glabs) 
- **Explorer с нодами:** [перейти](https://explorer.validatorvn.com/OG-Testnet/staking)
- **Официальный гайд по установке ноды:** [перейти](https://github.com/trusted-point/0g-tools)

**Перейдем к инструкции по установке ноды. Впереди нас ждет несколько этапов:**

## Первый этап - Проходим квесты на Galxe.

**Переходим на страницу 0G Labs в [Galxe](https://app.galxe.com/quest/0Glabs/GCZJvthyvM?) и проходим квесты. Подписываемся на социальные сети проекта, а также взаимодействуем с Twitter'ом. После прохождения заданий можно смело приступать к следующему этапу.**

## Второй этап - Установка необходимого ПО для запуска ноды.

**1. Обновляем пакеты сервера:**

```
sudo apt update && sudo apt upgrade -y
```

**2. Устанавливаем необходимое ПО:**

```
sudo apt install curl git jq build-essential gcc unzip wget lz4 -y
```

**3. Устанавливаем Golang(GO) одной командой:**

```
cd $HOME && \
ver="1.21.3" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile && \
source ~/.bash_profile && \
go version
```

**4. Устанавливаем бинарный файл. Вводим команды:**

```
git clone https://github.com/0glabs/0g-evmos.git
```

```
cd 0g-evmos
```

```
git checkout v1.0.0-testnet
```

```
make install
```

```
evmosd version
```

**5. Настраиваем переменные. Ничего менять не нужно!:**

```
echo 'export MONIKER="My_Node"' >> ~/.bash_profile
echo 'export CHAIN_ID="zgtendermint_9000-1"' >> ~/.bash_profile
echo 'export WALLET_NAME="wallet"' >> ~/.bash_profile
echo 'export RPC_PORT="26657"' >> ~/.bash_profile
source $HOME/.bash_profile
```

**6. Инициализируем ноду:**

```
cd $HOME
evmosd init $MONIKER --chain-id $CHAIN_ID
evmosd config chain-id $CHAIN_ID
evmosd config node tcp://localhost:$RPC_PORT
evmosd config keyring-backend os
```

**7. Устанавливаем генезис файл:**

```
wget https://github.com/0glabs/0g-evmos/releases/download/v1.0.0-testnet/genesis.json -O $HOME/.evmosd/config/genesis.json
```

**8. Добавляем peer'ы и seed'ы в config.toml:**

```
PEERS="1248487ea585730cdf5d3c32e0c2a43ad0cda973@peer-zero-gravity-testnet.trusted-point.com:26326" && \
SEEDS="8c01665f88896bca44e8902a30e4278bed08033f@54.241.167.190:26656,b288e8b37f4b0dbd9a03e8ce926cd9c801aacf27@54.176.175.48:26656,8e20e8e88d504e67c7a3a58c2ea31d965aa2a890@54.193.250.204:26656,e50ac888b35175bfd4f999697bdeb5b7b52bfc06@54.215.187.94:26656" && \
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.evmosd/config/config.toml
```

**8.1 Меняем порты (необязательный шаг):**

```
EXTERNAL_IP=$(wget -qO- eth0.me) \
PROXY_APP_PORT=26658 \
P2P_PORT=26656 \
PPROF_PORT=6060 \
API_PORT=1317 \
GRPC_PORT=9090 \
GRPC_WEB_PORT=9091
```

```
sed -i \
    -e "s/\(proxy_app = \"tcp:\/\/\)\([^:]*\):\([0-9]*\).*/\1\2:$PROXY_APP_PORT\"/" \
    -e "s/\(laddr = \"tcp:\/\/\)\([^:]*\):\([0-9]*\).*/\1\2:$RPC_PORT\"/" \
    -e "s/\(pprof_laddr = \"\)\([^:]*\):\([0-9]*\).*/\1localhost:$PPROF_PORT\"/" \
    -e "/\[p2p\]/,/^\[/{s/\(laddr = \"tcp:\/\/\)\([^:]*\):\([0-9]*\).*/\1\2:$P2P_PORT\"/}" \
    -e "/\[p2p\]/,/^\[/{s/\(external_address = \"\)\([^:]*\):\([0-9]*\).*/\1${EXTERNAL_IP}:$P2P_PORT\"/; t; s/\(external_address = \"\).*/\1${EXTERNAL_IP}:$P2P_PORT\"/}" \
    $HOME/.evmosd/config/config.toml
```

```
sed -i \
    -e "/\[api\]/,/^\[/{s/\(address = \"tcp:\/\/\)\([^:]*\):\([0-9]*\)\(\".*\)/\1\2:$API_PORT\4/}" \
    -e "/\[grpc\]/,/^\[/{s/\(address = \"\)\([^:]*\):\([0-9]*\)\(\".*\)/\1\2:$GRPC_PORT\4/}" \
    -e "/\[grpc-web\]/,/^\[/{s/\(address = \"\)\([^:]*\):\([0-9]*\)\(\".*\)/\1\2:$GRPC_WEB_PORT\4/}" $HOME/.evmosd/config/app.toml
```

```
sed -i \
    -e "/\[api\]/,/^\[/{s/\(address = \"tcp:\/\/\)\([^:]*\):\([0-9]*\)\(\".*\)/\1\2:$API_PORT\4/}" \
    -e "/\[grpc\]/,/^\[/{s/\(address = \"\)\([^:]*\):\([0-9]*\)\(\".*\)/\1\2:$GRPC_PORT\4/}" \
    -e "/\[grpc-web\]/,/^\[/{s/\(address = \"\)\([^:]*\):\([0-9]*\)\(\".*\)/\1\2:$GRPC_WEB_PORT\4/}" $HOME/.evmosd/config/app.toml
```

**9. Устанавливаем минимальную цену:**

```
sed -i "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.00252aevmos\"/" $HOME/.evmosd/config/app.toml
```

**10. Создаем service файл:**

```
sudo tee /etc/systemd/system/ogd.service > /dev/null <<EOF
[Unit]
Description=OG Node
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=$(which evmosd) start --home $HOME/.evmosd
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```

**11. Запускаем ноду:**

```
sudo systemctl daemon-reload && \
sudo systemctl enable ogd && \
sudo systemctl restart ogd && \
sudo journalctl -u ogd -f -o cat
```

*Ожидаем, на экране начнут появляться значения height. Для этого, чтобы выйти из данного меню используем комбинацию клавиш CTRL + C. После чего делаем перерыв, ждем чтобы нода успешно синхронизировалась.*

**12. Проверим синхронизацию ноды. Введем команду:**

```
evmosd status | jq .SyncInfo
```

**В выводе может быть 2 значения - False и True. Если пишет false - значит нода успешно синхронизировалась, можно продолжать создание валидатора. Если пишет true - значит ждем еще.**

**Если Вы не хотите ждать синхронизации, то можете установить Snapshot. Для этого введите команды по очереди:**

```
wget https://rpc-zero-gravity-testnet.trusted-point.com/latest_snapshot.tar.lz4
```

```
sudo systemctl stop ogd
```

```
cp $HOME/.evmosd/data/priv_validator_state.json $HOME/.evmosd/priv_validator_state.json.backup
```

```
evmosd tendermint unsafe-reset-all --home $HOME/.evmosd --keep-addr-book
```

```
lz4 -d -c ./latest_snapshot.tar.lz4 | tar -xf - -C $HOME/.evmosd
```

```
mv $HOME/.evmosd/priv_validator_state.json.backup $HOME/.evmosd/data/priv_validator_state.json
```

```
sudo systemctl restart ogd && sudo journalctl -u ogd -f -o cat
```

```
evmosd status | jq .SyncInfo
```

**Блоки должны быстрее дойти, в статуcе будет писаться false.**

Второй этап подошел к концу. Переходим к третьему этапу - Создание валидатора.

## Третий этап - Создание валидатора

**1. Создаем кошелек для валидатора:**

```
evmosd keys add $WALLET_NAME
```

Если ранее Вы уже создавали кошелек, то его можно импортировать. Для этого введите команду:

```
evmosd keys add $WALLET_NAME --recover

# DO NOT FORGET TO SAVE THE SEED PHRASE
# You can add --recover flag to restore existing key instead of creating
```

**2. Прописываем пароль, после чего сервер отобразит Seed фразу кошелька, а также адрес. Сохраняем все данные в надежное место.**

**3. Запросим EVM адрес. Данный адрес понадобится для взаимодействия с краном:**

```
echo "0x$(evmosd debug addr $(evmosd keys show $WALLET_NAME -a) | grep hex | awk '{print $3}')"
```

*Ниже представлен пример вывода на сервере:*

https://github.com/trusted-point/0g-tools/raw/main/assets/hex_addr.PNG

**4. Отправляемся к [крану](https://faucet.0g.ai/), запрашиваем тестовые токены.**

**5. Возвращаемся к терминалу, сначала введем команду для проверки, что нода синхронизирована и работает исправно:**

```
evmosd status | jq .SyncInfo.catching_up
```

**Если нода синхронизирована, то вводим команду для проверки баланса:**

```
evmosd q bank balances $(evmosd keys show $WALLET_NAME -a)
```

*Ниже представлен пример того, что выведет сервер:*

![balance](https://github.com/Mozgiii9/0GLabsSetupTheNode/assets/74683169/cc28facf-b765-4901-852c-33942a56b696)

*Кран дает 100000000000000000 $AEVMOS. Для запуска валидатора нужно как минимум в 10 раз больше, следовательно запрашиваем токены в кране минимум еще 10 раз. После чего переходим к следующему шагу и будем создавать валидатор.*

**6. Перейдем к созданию валидатора. При желании Вы можете заменить значения website, details и identity на собственные. Введем команду:**

```
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
```

**7. Запросим адрес для делегирования токенов самому себе:**

```
evmosd q staking validator $(evmosd keys show $WALLET_NAME --bech val -a)
```

**8. Делегируем токены самому себе:**

```
evmosd tx staking delegate $(evmosd keys show $WALLET_NAME --bech val -a)  10000000000000000aevmos --from $WALLET_NAME --gas=500000 --gas-prices=99999aevmos -y
```

**9. Делегируем токены другому валидатору:**

```
evmosd tx staking delegate <VALIDATOR_ADDRESS> 10000000000000000aevmos - from $WALLET_NAME - gas=500000 - gas-prices=99999aevmos -y
```

**На данном этапе установка ноды 0G Labs подошла к концу. Ниже представлен список полезных команд для взаимодествия с нодой:**

## Список полезных команд:

**1. Проверка статуса ноды:**

```
evmosd status | jq
```

**2. Запрос сведений о пропущенных блоках, а также сведений о тюрьме валидатора:**

```
evmosd q slashing signing-info $(evmosd tendermint show-validator)
```

**3. Unjail валидатора:**

```
evmosd tx slashing unjail --from $WALLET_NAME --gas=500000 --gas-prices=99999aevmos -y
```

**4. перевод токенов между кошельками. <TO_WALLET> замените на собственное значение:**

```
evmosd tx bank send $WALLET_NAME <TO_WALLET> <AMOUNT>aevmos --gas=500000 --gas-prices=99999aevmos -y
```

**5. Запрос списка активных валидаторов:**

```
evmosd q staking validators -o json --limit=1000 \
| jq '.validators[] | select(.status=="BOND_STATUS_BONDED")' \
| jq -r '.tokens + " - " + .description.moniker' \
| sort -gr | nl
```

**6. Запрос списка неактивных валидаторов:**

```
evmosd q staking validators -o json --limit=1000 \
| jq '.validators[] | select(.status=="BOND_STATUS_UNBONDED")' \
| jq -r '.tokens + " - " + .description.moniker' \
| sort -gr | nl
```

**7. Просмотр логов:**

```
sudo journalctl -u ogd -f -o cat
```

**8. Проверка статуса синхронизации:**

```
evmosd status | jq .SyncInfo
```

**9. Проверка статуса ноды:**

```
evmosd status | jq
```

**10. Перезагрузка ноды:**

```
sudo systemctl restart ogd
```

**11. Остановка ноды:**

```
sudo systemctl stop ogd
```

**12. Удаление ноды:**

```
sudo systemctl stop ogd
sudo systemctl disable ogd
sudo rm /etc/systemd/system/ogd.service
rm -rf $HOME/.evmosd $HOME/0g-evmos
```

Полный список полезных команд для взаимодействия с нодой 0G Labs Вы можете просмотреть по [ссылке](https://github.com/trusted-point/0g-tools#useful-commands)


