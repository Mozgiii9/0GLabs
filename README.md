0G — это модульная цепочка искусственного интеллекта с масштабируемым программируемым уровнем доступности данных (DA), адаптированным для dapps с искусственным интеллектом. Его модульная технология обеспечивает беспрепятственное взаимодействие между цепочками, обеспечивая безопасность, устраняя фрагментацию и максимизируя возможности подключения. Проект появился на радаре еще около 2-х недель назад после инвестиции в $35M от Tier-1 фондов, а уже сегодня 0G запускают оплачиваемый тестнет. Нода будет оплачиваемая, об этом активно пишут модераторы проекта в Discord. Перед установкой ноды необходимо пройти квесты на Galxe. Давайте подробно рассмотрим инвестиции, а также требования к серверу:

Инвестировали: $35 000 000 (Hack VC, Delphi Digital, Animoca Brands, OKX и другие)

Характеристики сервера(рекомендованные): 

CPU: 4 cores;
RAM: 8 GB;
Storage: 500 GB SSD;
OS: Ubuntu 20.04

Перейдем к инструкции по установке ноды:

1. Проходим квесты на Galxe.

2. Обновляем пакеты сервера:

```
sudo apt update && sudo apt upgrade -y
```

3. Устанавливаем необходимое ПО:

```
sudo apt install curl git jq build-essential gcc unzip wget lz4 -y
```

4. Устанавливаем Golang(GO) одной командой:

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

5. Устанавливаем бинарный файл. Вводим команды:

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

6. Настраиваем переменные. Ничего менять не нужно!:

```
cd $HOME
evmosd init $MONIKER --chain-id $CHAIN_ID
evmosd config chain-id $CHAIN_ID
evmosd config node tcp://localhost:$RPC_PORT
evmosd config keyring-backend os
```

7. Устанавливаем релиз:

```
wget https://github.com/0glabs/0g-evmos/releases/download/v1.0.0-testnet/genesis.json -O $HOME/.evmosd/config/genesis.json
```

8. Добавляем seed'ы в config.toml:

```
PEERS="1248487ea585730cdf5d3c32e0c2a43ad0cda973@peer-zero-gravity-testnet.trusted-point.com:26326" && \
SEEDS="8c01665f88896bca44e8902a30e4278bed08033f@54.241.167.190:26656,b288e8b37f4b0dbd9a03e8ce926cd9c801aacf27@54.176.175.48:26656,8e20e8e88d504e67c7a3a58c2ea31d965aa2a890@54.193.250.204:26656,e50ac888b35175bfd4f999697bdeb5b7b52bfc06@54.215.187.94:26656" && \
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.evmosd/config/config.toml
```

9. Устанавливаем минимальную цену:

```
sed -i "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.00252aevmos\"/" $HOME/.evmosd/config/app.toml
```

10. Создаем service файл:

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

11. Запускаем ноду:

```
sudo systemctl daemon-reload && \
sudo systemctl enable ogd && \
sudo systemctl restart ogd && \
sudo journalctl -u ogd -f -o cat
```

Ожидаем, на экране начнут появляться значения height. Для этого, чтобы выйти из данного меню используем комбинацию клавиш CTRL + C. После чего делаем перерыв для того, чтобы нода успешно синхронизировалась.

12. Проверим синхронизацию ноды. Введем команду:

```
evmosd status | jq .SyncInfo
```

13.


