![image](https://github.com/Mozgiii9/0GLabsSetupTheNode/assets/74683169/efd19714-2463-4cbb-8a3c-0e469e92d673)

## Дата создания файла: 11.04.2024

## Дата обновления файла №1: 15.04.2024 (Добавлен Bash скрипт для установки ноды 0G Labs)

## Дата обновления файла №2: 20.04.2024 (Обновлен Bash скрипт для установки ноды 0G Labs)

## Даьа обновления файла №3: 25.04.2024 (Обновление требований к серверу(нужен именно NVMe SSD)

## Дата обновления файла №4: 13.05.2024 (Переход проекта с Cosmos на Kava)

## Обзор проекта:
[0G Labs](https://0g.ai/) — это модульная цепочка искусственного интеллекта с масштабируемым программируемым уровнем доступности данных (DA), адаптированным для dapps с искусственным интеллектом. Его модульная технология обеспечивает беспрепятственное взаимодействие между цепочками, обеспечивая безопасность, устраняя фрагментацию и максимизируя возможности подключения. Проект появился на радаре еще около 2-х недель назад после инвестиции в $35M от Tier-1 фондов, а уже сегодня 0G запускают оплачиваемый тестнет. На момент написания гайда установлено порядка ~300 нод, поэтому рекомендую не медлить и приступить к установке. Нода будет оплачиваемая, об этом активно пишут модераторы проекта в Discord. Перед установкой ноды необходимо пройти квесты на Galxe. Давайте подробно рассмотрим инвестиции, а также требования к серверу:

![image](https://github.com/Mozgiii9/0GLabsSetupTheNode/assets/74683169/84156744-897b-43e0-a189-d66b1c3cd20b)

**Инвестировали: $35 000 000 (Hack VC, Delphi Digital, Animoca Brands, OKX и другие)**

**Характеристики сервера(рекомендованные):**

**CPU: 4 cores;**

**RAM: 8 GB;**

**Storage: 500 GB SSD NVMe;**

**OS: Ubuntu 20.04**

Сервер с такой конфигурацией можно удобно отыскать здесь: [САЙТ](https://ru.hostings.info/hostings/filter_page#vps)

Официальные ресурсы проекта:

- **Веб-сайт:** [перейти](https://0g.ai/)
- **Discord:** [перейти](https://discord.com/invite/0glabs)
- **Twitter:** [перейти](https://twitter.com/0G_labs)
- **Telegram:** [перейти](https://t.me/web3_0glabs) 
- **Explorer с нодами:** [перейти](https://dashboard.nodebrand.xyz/0g-chain)
- **Официальный гайд по установке ноды:** [перейти](https://github.com/trusted-point/0g-tools)

**Перейдем к инструкции по установке ноды:**

## Установка ноды при помощи Bash скрипта:

**1. Обновляем пакеты сервера:**

```
sudo apt update && sudo apt upgrade -y
```

**2. Устанавливаем дополнительное ПО:**

```
sudo apt install curl git wget htop tmux build-essential jq make lz4 gcc unzip -y
```

**3. Устанавливаем скрипт от Nodes Guru:**

```
wget -q -O 0g.sh https://api.nodes.guru/0g.sh && sudo chmod +x 0g.sh && ./0g.sh && source $HOME/.bash_profile
```

**Скрипт запросит ввести название Вашего валидатора. После ввода начнется установка необходимого ПО для работы ноды. Если Вы увидели то же самое, что на скрине ниже, значит, что Ваша нода успешно установлена и можно переходить к следующему шагу:**

![image](https://github.com/Mozgiii9/0GLabsSetupTheNode/assets/74683169/831ba79a-b5e4-44e6-9abd-84e0517c8182)

**4. Устанавливаем Snapshot. Выполните команды по очереди:**

```
curl -Ls https://snapshots.liveraven.net/snapshots/testnet/zero-gravity/addrbook.json > $HOME/.0gchain/config/addrbook.json
```

```
PEERS=$(curl -s --max-time 3 --retry 2 --retry-connrefused "https://snapshots.liveraven.net/snapshots/testnet/zero-gravity/peers.txt")
if [ -z "$PEERS" ]; then
    echo "No peers were retrieved from the URL."
else
    echo -e "\nPEERS: "$PEERS""
    sed -i "s/^persistent_peers *=.*/persistent_peers = "$PEERS"/" "$HOME/.0gchain/config/config.toml"
    echo -e "\nConfiguration file updated successfully.\n"
fi
```

```
sudo systemctl stop 0g
```

```
cp $HOME/.0gchain/data/priv_validator_state.json $HOME/.0gchain/priv_validator_state.json.backup
```

```
rm -rf $HOME/.0gchain/data
```

```
curl -L http://snapshots.liveraven.net/snapshots/testnet/zero-gravity/zgtendermint_16600-1_latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.0gchain
```

```
mv $HOME/.0gchain/priv_validator_state.json.backup $HOME/.0gchain/data/priv_validator_state.json
```

```
sudo systemctl restart 0g
```

```
0gchaind status | jq .sync_info
```

**Для перехода к следующему шагу нода должна иметь статус "catching_up: false". Если нода имеет статус **"catching_up: true"** - ЖДИТЕ ПОКА НОДА СИНХРОНИЗИРУЕТСЯ И СТАТУС ИЗМЕНИТСЯ НА "false".**

![image](https://github.com/Mozgiii9/0GLabsSetupTheNode/assets/74683169/e2c48e67-3eb7-4db9-852c-d4172f66dda1)

**5. Создадим кошелек. Для этого выполним команду:**

```
0gchaind keys add wallet --eth
```

**Сервер запросит ввести пароль, который будет защищать кошелек.**

**Не забываем сохранить seed фразу в надежное место**

**Вы можете импортировать свой прошлый кошелек, если ставили ноду до обновления:**

```
0gchaind keys add wallet --recover --eth
```

**Введите пароль от кошелька**

![image](https://github.com/Mozgiii9/0GLabsSetupTheNode/assets/74683169/963439e5-e129-428b-82f8-2ca083d225c9)

**Чтобы получить адрес кошелька, который начинается с 0x, Вы можете сначала выполнить команду ниже, чтобы получить приватный ключ вашего ключа. Затем импортируйте возвращенный приватный ключ в кошелек Metamask, чтобы получить адрес кошелька.**

```
0gchaind keys unsafe-export-eth-key wallet
```

![image](https://github.com/Mozgiii9/0GLabsSetupTheNode/assets/74683169/f4d89462-d725-4d7f-894f-eec0dbf4ea2b)

![image](https://github.com/Mozgiii9/0GLabsSetupTheNode/assets/74683169/b024d75c-b7ad-421d-9af2-603e9b7041f7)

**Переходим в [кран](https://faucet.0g.ai/), запрашиваем токены. После проверим баланс кошелька:**

![image](https://github.com/Mozgiii9/0GLabsSetupTheNode/assets/74683169/2147977d-5b95-49be-84a6-8498dc857f92)

```
0gchaind q bank balances $(0gchaind keys show wallet -a)
```

![image](https://github.com/Mozgiii9/0GLabsSetupTheNode/assets/74683169/eb209ee1-1b6c-42a5-be30-29ab3270e00d)

## Кран дает вам 1000000ua0gi. Для того, чтобы создать ноду Вам необходимо 2000000ua0gi. Чтобы нода стала активной нужно минимум 10000000ua0gi (в 10 раз больше)!

**Еще раз проверим статус синхронизации ноды. Убедимся, что "catching_up : false":**

```
0gchaind status | jq .sync_info
```

**6. Создадим валидатор. Выполним команду:**

```
0gchaind tx staking create-validator \
--amount=2000000ua0gi \
--pubkey=$(0gchaind tendermint show-validator) \
--moniker="$VALIDATOR" \
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
```

**7. Копируем valoperaddress:**

![image](https://github.com/Mozgiii9/0GLabsSetupTheNode/assets/74683169/97041f5b-4754-4299-8097-498c58a1f62f)

**И делегируем токены самому себе при помощи команды:**

```
0gchaind tx staking delegate <validator address> --from wallet <amount>ua0gi --gas=auto --gas-adjustment=1.4 -y

> Замените <validator address> на адрес валидатора, которому Вы хотите делегировать токены;
> Замените <amount> на количество токенов, которое Вы хотите делегировать.
```

![image](https://github.com/Mozgiii9/0GLabsSetupTheNode/assets/74683169/8c80511d-7880-4b6b-988b-ac104c963704)

**8. Проверим логи:**

```
sudo journalctl -u 0g -f
```

**9. Заполняем форму на валидатора:**

![image](https://github.com/Mozgiii9/0GLabsSetupTheNode/assets/74683169/16bd60f4-f70f-4c1a-8d2d-5f4d6b3ffb05)

**Удалить ноду:**

```
sudo systemctl stop 0g
```

```
sudo systemctl disable 0g
```

```
sudo rm -rf $(which 0gchaind) $HOME/.0gchain
```

## Обязательно проведите собственный ресерч проектов перед тем как ставить ноду. Сообщество NodeRunner не несет ответственность за Ваши действия и средства. Помните, проводя свой ресёрч, Вы учитесь и развиваетесь.

## Связь со мной: [Telegram(@M0zgiii)](https://t.me/m0zgiii)
## Мои соц. сети: [Twitter](https://twitter.com/m0zgiii)



