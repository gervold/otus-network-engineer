## EIGRP

#### Цель:
Настроить EIGRP в С.-Петербург;
Использовать named EIGRP

#### Описание/Пошаговая инструкция выполнения домашнего задания:
В офисе С.-Петербург настроить EIGRP.
- R32 получает только маршрут по умолчанию.
- R16-17 анонсируют только суммарные префиксы.
- Использовать EIGRP named-mode для настройки сети. 
- Настройка осуществляется одновременно для IPv4 и IPv6.


## Схема стенда
![img.png](img.png)
![img_1.png](img_1.png)
### Общая информация

<details> 

<summary> Минимальная настройка </summary>

```
router eigrp NM_EIGRP
address-family ipv4 autonomous-system 1
eigrp router-id 18.18.18.18
af-interface default
shutdown

```

Редистрибъюция маршрута через topology base

</details>



<details> 

<summary>Полезные команды</summary>

```
sh ip route
sh ipv6 route
sh ip eigrp topology
sh ipv6 eigrp topology
sh eigrp protocols
sh ip eigrp neighbors
sh ipv6 eigrp neighbors
sh ip eigrp topology all-links
sh ipv6 eigrp topology all-links

```
</details>

<details>

<summary> Описание протокола </summary>

Enhanced Interior Gateway Routing Protocol (EIGRP)

Протокол маршрутизации, разработанный фирмой Cisco на основе протокола IGRP той же фирмы. 

EIGRP использует механизм DUAL (Diffusing Update ALgorithm) для выбора наиболее короткого маршрута. 




</details>

R16 и R17 - суммаризация




 
### Выполнение

### Общие действия


R18
```
ip route 0.0.0.0 0.0.0.0 10.5.0.6
ip route 0.0.0.0 0.0.0.0 10.5.0.14
!
ipv6 route ::/0 ethernet 0/2
ipv6 route ::/0 ethernet 0/3
```

```
router eigrp NM_EIGRP
  address-family ipv4 autonomous-system 1
  eigrp router-id 18.18.18.18
  af-interface default
  shutdown
```
! Перехожу в режим конфигурации address-family для протокола IPv4 при помощи следующей команды
! Перевела все интерфейсы, которые будут участвовать в процессе EIGRP, в состояние shutdown

```
  ! Объявила сети, которые будут участвовать в процессе
  network 192.168.2.18 0.0.0.0
  network 10.2.0.0 0.0.0.1
  network 10.2.0.2 0.0.0.1
```

```
 ! Настроила интерфейсы, участвующие в процессе
  af-interface Loopback 0
   no shutdown
   ! Перевожу интерфейс в пассивное состояние (по-умолчанию активно)
   passive-interface
   exit
  af-interface ethernet 0/0
   no shutdown
   exit
  af-interface ethernet 0/1
   no shutdown
   exit
  exit
```



на R18 - задать и дальше его ориджинайтить вниз



Настройка суммаризации на маршрутизаторах R16 и R17.

```
router eigrp NM_EIGRP
 address-family ipv4 autonomous-system 1
  af-interface ethernet 0/2
   summary-address 192.168.2.0 255.255.255.0
   summary-address 172.16.2.0 255.255.255.0
   summary-address 100.2.0.0 255.255.254.0
   summary-address 10.2.0.0 255.255.255.0
   exit
  exit
 exit
exit
!

conf t
!
router eigrp NM_EIGRP
 address-family ipv6 autonomous-system 1
  af-interface ethernet 0/3
   summary-address 2001:AAAA:BB02::/48
   exit
  exit
 exit
exit
```

Проверить на R18 и R32, что сначала стало много маршрутов, а потом меньше


Маршрут по умолчанию для R32

Через prefix-list и distribute-list.



### Выполнение

[статья](https://networklessons.com/eigrp/eigrp-named-mode-configuration)

R18(config)#router eigrp ?
  <1-65535>  Autonomous System
  WORD       EIGRP Virtual-Instance Name

конфигурация адресного семейства не включает маршрутизацию IPv4, как традиционная конфигурация IPv4 EIGRP

Именованный EIGRP использует функцию семейства адресов (address family, AF) для унификации процесса настройки при реализации как IPv4, так и IPv6.


R18(config-router)#address-family ipv4 autonomous-system 2042

R18(config-router-af)#eigrp router-id 18.18.18.18

R18(config-router)#address-family ipv4 autonomous-system 2042
R18(config-router-af)#af-interface default
R18(config-router-af-interface)#shutdown
R18(config-router-af-interface)#exit
R18(config-router-af)#af-interface Ethernet 0/1
R18(config-router-af-interface)#no shutdown
R18(config-router-af-interface)#exit
R18(config-router-af)#af-interface Ethernet 0/0
R18(config-router-af-interface)#no shutdown
R18(config-router-af-interface)#


Прверка что EIGRP заработал:
```
R18#sh eigrp protocols
EIGRP-IPv4 VR(SPB-NET) Address-Family Protocol for AS(2042)
  Metric weight K1=1, K2=0, K3=1, K4=0, K5=0 K6=0
  Metric rib-scale 128
  Metric version 64bit
  NSF-aware route hold timer is 240
  Router-ID: 18.18.18.18
  Topology : 0 (base)
    Active Timer: 3 min
    Distance: internal 90 external 170
    Maximum path: 4
    Maximum hopcount 100
    Maximum metric variance 1
    Total Prefix Count: 0
    Total Redist Count: 0

EIGRP-IPv6 VR(SPB-NET) Address-Family Protocol for AS(2042)
  Metric weight K1=1, K2=0, K3=1, K4=0, K5=0 K6=0
  Metric rib-scale 128
  Metric version 64bit
  NSF-aware route hold timer is 240
  Router-ID: 200.0.1.18
  Topology : 0 (base)
    Active Timer: 3 min
    Distance: internal 90 external 170
    Maximum path: 16
    Maximum hopcount 100
    Maximum metric variance 1
    Total Prefix Count: 6
    Total Redist Count: 0
```

```
R18(config-router)#address-family ipv4 autonomous-system 2042
R18(config-router-af)#af-interface default
R18(config-router-af-interface)#shutdown
R18(config-router-af-interface)#exit
R18(config-router-af)#af-interface Ethernet 0/1
R18(config-router-af-interface)#no shutdown
R18(config-router-af-interface)#exit
R18(config-router-af)#af-interface Ethernet 0/0
R18(config-router-af-interface)#no shutdown
R18(config-router-af-interface)#exit
R18(config-router-af)#exit
```
```
R18(config-router)#address-family ipv6 autonomous-system 2042
R18(config-router-af)#af-interface default
R18(config-router-af-interface)#shutdown
R18(config-router-af-interface)#exit
R18(config-router-af)#af-interface Ethernet 0/0
R18(config-router-af-interface)#no shutdown
R18(config-router-af-interface)#exit
R18(config-router-af)#af-interface Ethernet 0/1
R18(config-router-af-interface)#no shutdown
R18(config-router-af-interface)#exit
```

```
R18#
R18#sh ip eigrp topology all-links
EIGRP-IPv4 VR(SPB-NET) Topology Table for AS(2042)/ID(18.18.18.18)
Codes: P - Passive, A - Active, U - Update, Q - Query, R - Reply,
       r - reply Status, s - sia Status

P 10.0.1.0/24, 1 successors, FD is 131072000, serno 2
        via Connected, Ethernet0/0
P 10.0.0.0/24, 1 successors, FD is 131072000, serno 1
        via Connected, Ethernet0/1

```

```
R18#sh ip eigrp topology
EIGRP-IPv4 VR(SPB-NET) Topology Table for AS(2042)/ID(18.18.18.18)
Codes: P - Passive, A - Active, U - Update, Q - Query, R - Reply,
       r - reply Status, s - sia Status

P 10.0.1.0/24, 1 successors, FD is 131072000
        via Connected, Ethernet0/0
P 10.0.0.0/24, 1 successors, FD is 131072000
        via Connected, Ethernet0/1

R18#
```



```
R16(config)#router eigrp SPB-NET
R16(config-router)#address-family ipv4 unicast autonomous-system 2042
R16(config-router-af)#network 10.0.3.16 0.0.0.255
R16(config-router-af)#
*Jul  9 11:58:40.296: %DUAL-5-NBRCHANGE: EIGRP-IPv4 2042: Neighbor 10.0.3.32 (Ethernet0/3) is up: new adjacency
R16(config-router-af)#end
R16#
*Jul  9 11:58:51.581: %SYS-5-CONFIG_I: Configured from console by console
R16#show ip ei
R16#show ip eigrp ne
R16#show ip eigrp neighbors
EIGRP-IPv4 VR(SPB-NET) Address-Family Neighbors for AS(2042)
H   Address                 Interface              Hold Uptime   SRTT   RTO  Q  Seq
                                                   (sec)         (ms)       Cnt Num
0   10.0.3.32               Et0/3                    14 00:00:23   14   100  0  2
```


```
R32(config)#router ei
R32(config)#router eigrp SPB-NET
R32(config-router)#address-family ipv4 unicast autonomous-system 2042
R32(config-router-af)#netwo
R32(config-router-af)#network
R32(config-router-af)#network
R32(config-router-af)#network 123.123.123.123 0.0.0.0
R32(config-router-af)#network 10.0.3.32 0.0.0.255
R32(config-router-af)#end
```

```
R16#show ip route
Gateway of last resort is not set
      10.0.0.0/8 is variably subnetted, 2 subnets, 2 masks
C        10.0.3.0/24 is directly connected, Ethernet0/3
L        10.0.3.16/32 is directly connected, Ethernet0/3
      123.0.0.0/32 is subnetted, 1 subnets
D        123.123.123.123 [90/1024640] via 10.0.3.32, 00:01:17, Ethernet0/3
```



Роутер ID по умолчанию равен IP адресу включенного интерфейса: 
```
Routing Protocol is "eigrp 2042"
  Outgoing update filter list for all interfaces is not set
  Incoming update filter list for all interfaces is not set
  Default networks flagged in outgoing updates
  Default networks accepted from incoming updates
  EIGRP-IPv4 VR(SPB-NET) Address-Family Protocol for AS(2042)
    Metric weight K1=1, K2=0, K3=1, K4=0, K5=0 K6=0
    Metric rib-scale 128
    Metric version 64bit
    NSF-aware route hold timer is 240
    Router-ID: 10.0.3.16
    Topology : 0 (base)
      Active Timer: 3 min
      Distance: internal 90 external 170
      Maximum path: 4
      Maximum hopcount 100
      Maximum metric variance 1
      Total Prefix Count: 2
```
Сменим: 
```
R16(config-router)# address-family ipv4 unicast autonomous-system 2042
R16(config-router-af)#eigrp router-id 16.16.16.16
```
```
Routing Protocol is "eigrp 2042"
  Outgoing update filter list for all interfaces is not set
  Incoming update filter list for all interfaces is not set
  Default networks flagged in outgoing updates
  Default networks accepted from incoming updates
  EIGRP-IPv4 VR(SPB-NET) Address-Family Protocol for AS(2042)
    Metric weight K1=1, K2=0, K3=1, K4=0, K5=0 K6=0
    Metric rib-scale 128
    Metric version 64bit
    NSF-aware route hold timer is 240
    Router-ID: 16.16.16.16
    Topology : 0 (base)
      Active Timer: 3 min
      Distance: internal 90 external 170
      Maximum path: 4
      Maximum hopcount 100
      Maximum metric variance 1
      Total Prefix Count: 2
      Total Redist Count: 0
```

При настройке IPv6 не будем указывать network, тогда 

```
R32#show ipv6 protocol
IPv6 Routing Protocol is "connected"
IPv6 Routing Protocol is "application"
IPv6 Routing Protocol is "ND"
IPv6 Routing Protocol is "eigrp 2042"
EIGRP-IPv6 VR(SPB-NET) Address-Family Protocol for AS(2042)
  Metric weight K1=1, K2=0, K3=1, K4=0, K5=0 K6=0
  Metric rib-scale 128
  Metric version 64bit
  NSF-aware route hold timer is 240
  Router-ID: 32.32.32.32
  Topology : 0 (base)
    Active Timer: 3 min
    Distance: internal 90 external 170
    Maximum path: 16
    Maximum hopcount 100
    Maximum metric variance 1
    Total Prefix Count: 2
    Total Redist Count: 0

  Interfaces:
    Ethernet0/0
    Loopback0
  Redistribution:
    None
```

Автоматически будут распространены адреса со всех интерфейсов:
```
  Interfaces:
    Ethernet0/0
    Loopback0
```

В случае IPv4, где мы указывали `network` – будут только специфичные сети:
```
R32#show ip protocol
*** IP Routing is NSF aware ***
***
  Routing for Networks:
    10.0.3.0/24
    123.123.123.123/32
```

Установка для IPv6 происходит на Link-Local адресе:
```
R16#show ipv6 eigrp neighbors
EIGRP-IPv6 VR(SPB-NET) Address-Family Neighbors for AS(2042)
H   Address                 Interface              Hold Uptime   SRTT   RTO  Q  Seq
                                                   (sec)         (ms)       Cnt Num
0   Link-local address:     Et0/3                    13 00:01:11 1597  5000  0  2
    FE80::32
```

Проверка распространения тестового IPv6 адреса с R32:
```
R16#show ipv6 route eigrp
IPv6 Routing Table - default - 4 entries
***
D   2001:0:16:321::123/128 [90/1024640]
     via FE80::32, Ethernet0/3

```

По умолчанию:
```
Automatic Summarization: disabled
```





### Маршрут по умолчанию

Не можем делать как в OSPF, делаем `network 0.0.0.0`

```
  !
  topology base
  exit-af-topology
  network 0.0.0.0
 exit-address-family
 !
```
хз зачем

```
no ip route *
!
no ipv6 route ::/0 Ethernet0/0 FE80::16
!
```


### Суммаризация 

Для демонстрации суммаризации маршрутов немного переделаем дизайн сети – разобъем префикс
`10.0.2.0/255` на 4-е `/30` подсети и объединим ими R16, R17, SW9, SW10

Таким образом создадим условия для агрегации нескольких /30 маршрутов в один /24 на маршрутизаторах R16 и R17.


### Для настройки OSPF связности между маршрутизаторами и коммутаторами

no switchport 

и назначем ему IP адрес

