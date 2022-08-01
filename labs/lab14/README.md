## IPSec over GRE, DmVPN

### Цель:
- Настроить GRE поверх IPSec между офисами Москва и С.-Петербург
- Настроить DMVPN поверх IPSec между офисами Москва и Чокурдах, Лабытнанги

### Описание/Пошаговая инструкция выполнения домашнего задания:

В этой самостоятельной работе мы ожидаем, что вы самостоятельно:

- Настроите GRE поверх IPSec между офисами Москва и С.-Петербург.
- Настроите DMVPN поверх IPSec между Москва и Чокурдах, Лабытнанги.
- Все узлы в офисах в лабораторной работе должны иметь IP связность.


<details> 

<summary> Описание </summary>  

`GRE` не обеспечивает шифрование. 
Если хотим делать шифрование, то делаем GRE поверх IPSec или DMVPN поверх IPSec.

`IPsec` (сокращение от IP Security) — набор протоколов для обеспечения защиты данных, передаваемых по межсетевому протоколу IP. Позволяет осуществлять подтверждение подлинности (аутентификацию), проверку целостности и/или шифрование IP-пакетов. IPsec также включает в себя протоколы для защищённого обмена ключами в сети Интернет. В основном, применяется для организации VPN-соединений.

Состав IPSec:

![img.png](img.png)

Фазы `IKE`.

Туннель устанавливается в два этапа (фазы):
1. `Phase 1` – согласование метода идентификации, алгоритм шифрования, алгоритм хеширования и группа Diffie Hellman
2. `Phase 2` – генерируются ключи для шифрования данных. 2 фаза может начать работу только после установления первой фазы.

![img_1.png](img_1.png)

<details>

<summary> IPSec в RFC: </summary>

- RFC 2401 	IPSec
- RFC 2402 	AH
- RFC 2406 	ESP
- RFC 2409 	IKE

</details>

`AH` (`Authentication Header`) – протокол заголовка идентификации. 
Обеспечивает **целостность** путём проверки того, что ни один бит в защищаемой части пакета не был изменён во время передачи.  
Использование AH может вызвать проблемы, например, при прохождении пакета через NAT устройство. 
NAT меняет IP адрес пакета, чтобы разрешить доступ в Интернет с закрытого локального адреса. 
Т.к. пакет в таком случае изменится, то контрольная сумма AH станет неверной. 
Также стоит отметить, что AH разрабатывался только для обеспечения целостности. 
Он не гарантирует конфиденциальности путём шифрования содержимого пакета.

`ESP` (`Encapsulating Security Protocol`) – инкапсулирующий протокол безопасности, который обеспечивает **и целостность и конфиденциальность**. 
В режиме транспорта ESP заголовок находится между оригинальным IP заголовком и заголовком TCP или UDP. 
В режиме туннеля заголовок ESP размещается между новым IP заголовком и полностью зашифрованным оригинальным IP пакетом.

`ISAKMP` (`Internet Security Association and Key Management Protocol`) — протокол, используемый для первичной настройки соединения, взаимной аутентификации конечными узлами друг друга и обмена секретными ключами.

</details>

<details> 

<summary> Полезные команды </summary>
 
```
sh crypto isakmp peers
sh crypto session
sh crypto isakmp policy 
```

</details>

### Выполнение

### Настроите GRE поверх IPSec между офисами Москва и С.-Петербург.

На R18 подняты `Tunnel100` и `Tunnel101`.
Будем настраивать IPSec на них.

R15:

```
crypto isakmp policy 10
 encr aes
 authentication pre-share
 group 2
crypto isakmp key OLOLOLO address 204.2.0.18     
!
!
crypto ipsec transform-set GRE-IPSEC esp-3des esp-sha-hmac 
 mode transport
!
crypto ipsec profile PROTECT-GRE
 set transform-set GRE-IPSEC 
!

interface Tunnel 100
 tunnel protection ipsec profile PROTECT-GRE
 exit
exit
```

На R18 настройки симметричны (за исключением адреса противоположной точки).

До применения профиля шифрования:

![img_2.png](img_2.png)

После применения профиля шифрования:

![img_3.png](img_3.png)

Аналогично настраивается и шифрование тоннеля Tunnel 101.


### Настроите DMVPN поверх IPSec между Москва и Чокурдах, Лабытнанги.

В целом настраиваем аналогично R14, R15, R28, R27, с применением того же профиля (см. коммиты).

Посмотрим, как выглядит трафик между Чокхурдах и Лабынтаги до применения профилей:

```
R28#ping 10.200.0.3
Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 10.200.0.3, timeout is 2 seconds:
!!!!!
Success rate is 100 percent (5/5), round-trip min/avg/max = 1/3/7 ms

R28#ping 10.201.0.3
Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 10.201.0.3, timeout is 2 seconds:
!!!!!
Success rate is 100 percent (5/5), round-trip min/avg/max = 1/1/1 ms
```

![img_5.png](img_5.png)

Видна инкапсуляция заголовков и нешифрованные данные.

После применения IPsec профиля трафик приобретает следующий вид:

![img_6.png](img_6.png)

![img_7.png](img_7.png)

Видно, что было применено шифрование.

### Команды для дебага и проверки правильности работы

```
R15#sh crypto isakmp peers
Peer: 52.0.3.28 Port: 500 Local: 100.1.100.15
 Phase1 id: 52.0.3.28
Peer: 52.0.5.27 Port: 500 Local: 100.1.100.15
 Phase1 id: 52.0.5.27
Peer: 204.2.0.18 Port: 500 Local: 100.1.100.15
 Phase1 id: 204.2.0.18
R15#
```

<details>

<summary> и еще </summary>

```
R15#sh crypto isakmp policy

Global IKE policy
Protection suite of priority 10
	encryption algorithm:	AES - Advanced Encryption Standard (128 bit keys).
	hash algorithm:		Secure Hash Standard
	authentication method:	Pre-Shared Key
	Diffie-Hellman group:	#2 (1024 bit)
	lifetime:		86400 seconds, no volume limit
```

```
R15#sh crypto session
Crypto session current status

Interface: Tunnel100
Session status: UP-ACTIVE
Peer: 204.2.0.18 port 500
  Session ID: 0
  IKEv1 SA: local 100.1.100.15/500 remote 204.2.0.18/500 Active
  Session ID: 0
  IKEv1 SA: local 100.1.100.15/500 remote 204.2.0.18/500 Active
  IPSEC FLOW: permit 47 host 100.1.100.15 host 204.2.0.18
        Active SAs: 4, origin: crypto map

Interface: Tunnel200
Session status: UP-ACTIVE
Peer: 52.0.3.28 port 500
  Session ID: 0
  IKEv1 SA: local 100.1.100.15/500 remote 52.0.3.28/500 Active
  IPSEC FLOW: permit 47 host 100.1.100.15 host 52.0.3.28
        Active SAs: 2, origin: crypto map

Interface: Tunnel200
Session status: UP-ACTIVE
Peer: 52.0.5.27 port 500
  Session ID: 0
  IKEv1 SA: local 100.1.100.15/500 remote 52.0.5.27/500 Active
  IPSEC FLOW: permit 47 host 100.1.100.15 host 52.0.5.27
        Active SAs: 2, origin: crypto map
```

</details>

### Настройка сертификатов

Главный минус предыдущего подхода – необходимость предварительного распространения пароля.
В случае большого и динамичеси меняющегося количество участников `DMVPN` сети (`SPOKE`-ов), ручное распространение паролей становится сложной задачей.

Поэтому поднимем свой центр сертификации на `HUB`-роутере, при помощи которого будем выписывать сертификаты и выдавать их участникам сети.

Далее, по выданным сертификатам, будет производиться авторизация участников сети.

План:
1. Настроить центр сертификации (`CA`)
2. Послать запросы на выдачу сертификатов и выписать сертификаты
3. Настроить на роутерах работу `IPSec` через сертификаты


Определим следующие роли:
- R15 – `CA` + участник сети
- R27, R28 – рядовые участники сети.

Параметры сертификатов:
```
subject-name CN=R15,OU=Moscow,O=Kolxoz,C=RU
subject-name CN=R27,OU=Labintagi,O=Kolxoz,C=RU
subject-name CN=R28,OU=Chokhurdax,O=Kolxoz,C=RU
```

#### Настройка центра сертификации

#### Настройка CA
На R15 выполним:

```
ip domain-lookup
ip domain-name kolxoz.net

ip http server
crypto key generate rsa general-keys label CA exportable modulus 2048
crypto pki server CA
no shutdown
password:OLOLOLOL
```

#### Настройка клиента и запрос сертификата

На обоих маршрутизаторах R27, R28, R15 выполнить:
```
R27(config)#ip domain-lookup
R27(config)#ip domain-name kolxoz.net

R27(config)#crypto key generate rsa label VPN modulus 2048
```
Настройка `trust point`:
```
R27(config)#crypto pki trustpoint VPN
R27(ca-trustpoint)#enrollment url http://100.1.100.15
R27(ca-trustpoint)#subject-name CN=R28,OU=Chokhurdax,O=Kolxoz,C=RU
R27(ca-trustpoint)#rsakeypair VPN
R27(ca-trustpoint)#revocation-check none
R27(ca-trustpoint)#exit
```

Запросить запросить и проверить сертификат CA и запросить сертификат для себя:
```
R27(config)#crypto pki authenticate VPN
Certificate has the following attributes:
       Fingerprint MD5: 282EA3CC AE4FE6E2 A1E9C0D0 C679758A
      Fingerprint SHA1: 36A18CDD 11712E02 352B17FB 33069A85 88EE8501

% Do you accept this certificate? [yes/no]: yes
Trustpoint CA certificate accepted.

```

Запросить сертификат для маршрутизатора:
```
R27(config)#crypto pki enroll VPN
```
После отправки запрос можно посмотреть на CA:
```
R15#show crypto pki server CA request
***
Router certificates requests:
ReqID  State      Fingerprint                      SubjectName
--------------------------------------------------------------
1      pending    8EF30F1B6264C558C44D58B768DAAEC6 hostname=R28.kolxoz.net,cn=R28,ou=Chokhurdax,o=Kolxoz,c=RU```
```
Подтвердить выпуск:
```
R15#crypto pki server CA grant 1
```
или 
```
crypto pki server CA grant all
```
После подтверждения запроса статус `pending` меняется на `granted`.
```
R15#show crypto pki server CA request
Router certificates requests:
ReqID  State      Fingerprint                      SubjectName
--------------------------------------------------------------
1      granted    8EF30F1B6264C558C44D58B768DAAEC6 hostname=R28.kolxoz.net,cn=R28,ou=Chokhurdax,o=Kolxoz,c=RU```
```

C запрашивающего маршрутизатора можно посмотреть полученный сертификат:

<details>

```
R28#sh crypto pki certificates
Certificate
  Status: Available
  Certificate Serial Number (hex): 02
  Certificate Usage: General Purpose
  Issuer:
    cn=CA
  Subject:
    Name: R28.kolxoz.net
    hostname=R28.kolxoz.net
    cn=R28
    ou=Chokhurdax
    o=Kolxoz
    c=RU
  Validity Date:
    start date: 21:14:02 EET Aug 1 2022
    end   date: 21:14:02 EET Aug 1 2023
  Associated Trustpoints: VPN

CA Certificate
  Status: Available
  Certificate Serial Number (hex): 01
  Certificate Usage: Signature
  Issuer:
    cn=CA
  Subject:
    cn=CA
  Validity Date:
    start date: 21:08:04 EET Aug 1 2022
    end   date: 21:08:04 EET Jul 31 2025
  Associated Trustpoints: VPN
```
</details>

#### Настройка IPSec

В целом далее настройки `IPSec` и применение профиля аналогичны описанным выше, но тип аутентификации меняется с `authentication pre-share` на `authentication rsa-sig`.

(подробности в коммите)

После применения настроек и выписывания сертификатов между (для примера R28 и R15) видно, что пиры теперь выглядят по другому:
```
R28#sh crypto isakmp peers
Peer: 100.1.100.15 Port: 500 Local: 52.0.3.28
 Phase1 id: R15.kolxoz.net
```
```
R15#sh crypto isakmp peers
Peer: 52.0.3.28 Port: 500 Local: 100.1.100.15
 Phase1 id: R28.kolxoz.net
```

Связность не потерялась:
```
R15#ping 10.200.0.4
Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 10.200.0.4, timeout is 2 seconds:
!!!!!
Success rate is 100 percent (5/5), round-trip min/avg/max = 5/5/6 ms
```

Содержимое зашифровано:
![img_8.png](img_8.png)




