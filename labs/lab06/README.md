## OSPF

### Цель:
Настроить OSPF офисе Москва.  
Разделить сеть на зоны.  
Настроить фильтрацию между зонами.  

### Описание/Пошаговая инструкция выполнения домашнего задания:

1. Маршрутизаторы R14-R15 находятся в зоне 0 - backbone.
2. Маршрутизаторы R12-R13 находятся в зоне 10. Дополнительно к маршрутам должны получать маршрут по умолчанию.
3. Маршрутизатор R19 находится в зоне 101 и получает только маршрут по умолчанию.
4. Маршрутизатор R20 находится в зоне 102 и получает все маршруты, кроме маршрутов до сетей зоны 101.
5. Настройка для IPv6 повторяет логику IPv4.



![img.png](img.png)

![img_2.png](img_2.png)

### Выполнение

Минимальная настройка OSPF:

```
router ospf 1
 router-id 15.15.15.15
exit

ipv6 router ospf 1
 router-id 15.15.15.15
exit
```


```
!
interface Loopback0
 ip ospf 10 area 0
 ipv6 ospf 10 area 0
 exit
!
interface Ethernet0/0
 ip ospf 10 area 0
 ipv6 ospf 10 area 0
 exit
!
```

Команды:
```
sh ip route
sh ip protocols – 
sh ip route static –

sh ipv6 route

Show ip ospf neighbor
Show ip route <ospf>
Show ip int brief
Show ip ospf database
Show ip ospf interface 
```

```
area 101 stub no-summary

default-information originate

distribute-list prefix-list Area101-Deny-IPV6 in
```




Area 101 - Total Stub


### Описание

#### OSPF (Open Shortest Path First) 

`OSPF` представляет собой протокол внутреннего шлюза (`Interior Gateway Protocol` — `IGP`). 
Работает внутри одной автономной системы (АС).  
Протокол _состояния канала_ – знает _все_ о своих каналах.

Маршрутизатор формирует таблицу топологии с использованием результатов вычислений, основанных на алгоритме кратчайшего пути (`SPF`, `Shortest Path First`) Дейкстры.

_Типы таблиц:_

1. Таблица соседей – разная для всех маршрутизаторов `show ip ospf neighbor`
2. Таблица топологии – у всех разная `show ip ospf database`
3. Таблица с лучшими маршрутами `show ip route`

LSDB - единственная одинаковая на всех устройствах табличка.

_Типы пакетов:_

1. `Hello` - обнаружение узлов, установка смежности. Рассказывает о состоянии канала:
есть интерфейс такой-то с такой-то емкостью, информация об этом идет в databases.
2. Дескриптор базы данных (`DBD`) - выполняется единожды, полная синхронизация баз данных. Выполняется раз в 30 минут.
3. Запрос состояния канала (`LSR`, `Link Status Request`) - запрос информации о каналах, которые интересуют
4. `LSU` - высылка обновления состояния канала (включает `LSA`)
5. Подтверждение `LSAck`.

Тоесть по таймеру каждые 30 мин выполняется DBD - LSR-запрос и получается LSU-ответ.<br>

_Роли маршрутизаторов:_

1. Внутренние и магистральные: 
- Внутренний - любой с интерфейсами внутри одной зоны
- Магистральный - находится в зоне 0

2. Граничные OSPF-маршрутизаторы:  

- `ABR` (`Area Border Router`) – на границе нескольких зон 
- `ASBR` (`Autonomous System Boundary Router`) – этот роутер может быть в любом месте, главное чтобы один из интерфейсов торчал во вне. 

![img_5.png](img_5.png)

3. `DR` (`Designated Router`) и его `BDR` (`Backup DR`)

Проблемы из-за `full mesh`: с масштабированием, много служебного трафика.  

![img_4.png](img_4.png)

Поэтому выделяется `Designated Router` (`DR`) и получается топология звезда.
Чтобы обеспечить отказоустойчивость - вводится `Backup DR` (`BDR`).
BDR ничего не шлет в сеть, только принимает.


![img_9.png](img_9.png)

На практике используются LSA типов 1-5, поэтому опишем их  
Типы `LSA`:
1. используется внутри зоны
2. используются только DR 
3. LSA 3 - работают между 2-мя зонами. Cуммарная информация о зоне, формируются только ABR, может передаваться между разными зонами.  У одного роутера может быть несколько ролей
4. LSA 4 - говорит, что есть ASBR где-то там в зоне. «Я знаю того кто знает, о внешних маршрутах» (ASBR), информация о самом хранителе маршрутов. Передается через зоны.
5. LSA 5 - работает напролом через все зоны. «Лавинная рассылка внешних маршрутов» 

Важно понимать маршрутизатор с какой ролью создает LSA.

Stub - получает маршруты LSA1,2,3 + машрут по умолчанию. Тоесть  в стаб не идет информация от ASBR.
Для выхода из зоны используется default. Нет внешних маршрутов.



![img_10.png](img_10.png)

Totally stub – информация о других зонах (LSA 3) – блокируется, идет только default.

![img_11.png](img_11.png)

Особенность для Stub и Total Stub – нельзя поставить ASBR (LSA 5), тоесть через stub-зоны нельзя _самостоятельно_ выходить в Интернет.
Тупики, в которые идет default.

![img_12.png](img_12.png)


В NSSA можно подключать ASBR для получения новых маршрутов.

![img_13.png](img_13.png)

Внутри Area 0 распространяются LSA 7 конвертированные в LSA 5:
![img_14.png](img_14.png)

### Зоны (Areas):

Проблема – требуется постоянная синхронизация в `LSDB`, что создает нагрузку в случае больших сетей.
После разбивки на зоны получаются разные таблички `LSDB` меньшего размера. Меньше нагрузки на оборудование.
Рекомендуемое количество подключенных устройств в зоне не более 50-ти.


Магистральная – зона 0 (backbone), транзитная.

В 3-х уровневой модели логично делать зону 0 на уровне ядра (тогда влезем в количество устройств),
Но ядро подключают и к зоне 1 (для дистрибуции).

![img_6.png](img_6.png)

К ней подключаются зоны других типов, например стабы:

![img_7.png](img_7.png)

И не только `stub`-ы: `total stub`, `NSSA` (`Not so stubby area`), `total NSSA`:

![img_8.png](img_8.png)



### Фильтрация 

Осуществляется по типу LSA:

- LSA 1-2  – общие команды, без вариаций
- LSA 3 – фильтры на основе префикс-листов, можно фильтровать только на ABR.
Не смотря на то что тут написано prefix - мы фильтруем именно LSA, но не сами префиксы.
Условно «вот это вот туда не анонсить!»
- По LSA 4 и 5 фильтров не существует:
  - LSA 4 - не фильтруется, так как служебный
  - LSA 5 - можно фильтровать на ASBR


В терминах 3-х уровневой модели – через area 0 будет реализован core layer, 
через area 10 – будет реализован Distribution layer.




```
interface Ethernet0/0
 no ip address
 ip ospf 1 area 0
!
interface Ethernet0/0.1
 ip ospf 1 area 0
```
```
clear ip ospf process  
```

По умолчанию переведем интерфейсы в passive-режим (hello-пакеты отсылаться не будут).

passive-interface default

И вручную зададим интерфейсы участвующие в обмене ospf

no passive-interface Ethernet0/0
no passive-interface Ethernet0/1
no passive-interface Ethernet0/3 

```
!
router ospf 1
 router-id 12.12.12.12
 passive-interface default
 no passive-interface Ethernet0/1
 no passive-interface Ethernet0/2
 no passive-interface Ethernet0/3
!


interface Loopback0
 ip ospf 10 area 0
 ipv6 ospf 10 area 0
exit
 
interface Ethernet0/0
 ip ospf 10 area 0
 ipv6 ospf 10 area 0
exit
 
 
```

### Default 

На ASBR-ах нужно указать, что они знают маршрут по умолчанию:

default-information originate

ip ospf network point-to-point


### План выполнения:
- объединение 2-х маршрутизаторов в одну зону (area 0)
- выделение R12 и R13 в area 10
- механизм prefix-list 
- выделение R19 в area 101
- выделение R20 в area 102 (prefix-list и distribute-list фильтрация)

### OSPF – одна зона
<details>

<summary> Объединим R14, R15 в area 0</summary>

Для начала можно просто объединить R12, R13 в рамках одной area.

</details>


Подключение к area 10 выглядит примерно след образом:

```
R15#configure terminal
R15(config)#int e0/1
R15(config-if)#ip ospf 1 area 10
R15(config-if)#end
```
После чего можно видеть, что соседство установлено и маршруты начали распространяться между зонами:

```
R15#show ip ospf neighbor

Neighbor ID     Pri   State           Dead Time   Address         Interface
14.14.14.14       1   FULL/BDR        00:00:36    10.0.5.14       Ethernet1/0
12.12.12.12       1   FULL/DR         00:00:39    10.0.1.12       Ethernet0/1
13.13.13.13       1   FULL/DR         00:00:35    10.0.2.13       Ethernet0/0
R15#
```

```
R15#show ip route ospf
...
Gateway of last resort is not set

      10.0.0.0/8 is variably subnetted, 9 subnets, 2 masks
O        10.6.66.14/32 [110/11] via 10.0.5.14, 00:10:09, Ethernet1/0
```
В том числе и между зонами (пометка `IA`):
```
R12#show ip route ospf

Gateway of last resort is not set

      10.0.0.0/8 is variably subnetted, 6 subnets, 2 masks
O IA     10.0.5.0/24 [110/20] via 10.0.2.14, 00:33:32, Ethernet0/2
                     [110/20] via 10.0.1.15, 00:04:18, Ethernet0/3
O IA     10.6.66.14/32 [110/11] via 10.0.2.14, 00:33:32, Ethernet0/2
```


#### Defaults

Способ №1

На R15 в настройках ospf делаем:
```
default-information originate
```

Задаем сам default:
```
R15(config)#ip route 0.0.0.0 0.0.0.0 30.0.0.21 name default_to_lamas
```

Проверяем:
```
R13#show ip route ospf
...
Gateway of last resort is 10.0.2.15 to network 0.0.0.0

O*E2  0.0.0.0/0 [110/1] via 10.0.2.15, 00:01:58, Ethernet0/2
      10.0.0.0/8 is variably subnetted, 6 subnets, 2 masks
O IA     10.0.5.0/24 [110/20] via 10.0.2.15, 02:59:04, Ethernet0/2
                     [110/20] via 10.0.1.14, 02:59:14, Ethernet0/3
O IA     10.6.66.14/32 [110/11] via 10.0.1.14, 02:59:14, Ethernet0/3
```

Способ 2

Принудительное распространение дефолта, даже если он не установлен:
```
R14(config-router)#default-information originate always
```

```
R14#show ip route
...
Gateway of last resort is not set
```

Видим, что теперь есть два маршрута по умолчанию:
```
R12#show ip route ospf
Gateway of last resort is 10.0.2.14 to network 0.0.0.0

O*E2  0.0.0.0/0 [110/1] via 10.0.2.14, 00:00:26, Ethernet0/2
                [110/1] via 10.0.1.15, 00:11:34, Ethernet0/3
      10.0.0.0/8 is variably subnetted, 6 subnets, 2 masks
O IA     10.0.5.0/24 [110/20] via 10.0.2.14, 03:08:50, Ethernet0/2
                     [110/20] via 10.0.1.15, 03:08:40, Ethernet0/3
O IA     10.6.66.14/32 [110/11] via 10.0.2.14, 03:08:50, Ethernet0/2
```

По умолчанию стоит E2 и внутренние косты не учитываются.
Если нужно учитывать внутренние косты, то нужно включить E1.


### Выделение total stub

R19 в Area 101 и получать только маршрут по умолчанию

Марщруты при подключении area 101 в режиме стандартной зоны:
```
ip ospf 1 area 101
```
Видим, что распространились все маршруты, никакой фильтрации нет:
```
R19#show ip route

Gateway of last resort is 10.0.3.14 to network 0.0.0.0

O*E2  0.0.0.0/0 [110/1] via 10.0.3.14, 00:00:06, Ethernet0/0
      10.0.0.0/8 is variably subnetted, 6 subnets, 2 masks
O IA     10.0.1.0/24 [110/20] via 10.0.3.14, 00:00:06, Ethernet0/0
O IA     10.0.2.0/24 [110/20] via 10.0.3.14, 00:00:06, Ethernet0/0
C        10.0.3.0/24 is directly connected, Ethernet0/0
L        10.0.3.19/32 is directly connected, Ethernet0/0
O IA     10.0.5.0/24 [110/20] via 10.0.3.14, 00:00:06, Ethernet0/0
O IA     10.6.66.14/32 [110/11] via 10.0.3.14, 00:00:06, Ethernet0/0
R19#
```

Тоесть получаются все маршруты, всех типов LSA.

Поменяем на обоих соседях (R14, R19) тип area на total stub, чтобы внутрь проходил только маршрут по умолчанию:
```area 101 stub no-summary```

Теперь R19 получает от R14 только маршрут по умолчанию (остальные маршруты были отфильтрованы):

```
R19#show ip route
Gateway of last resort is 10.0.3.14 to network 0.0.0.0
O*IA  0.0.0.0/0 [110/11] via 10.0.3.14, 00:00:27, Ethernet0/0
      10.0.0.0/8 is variably subnetted, 2 subnets, 2 masks
C        10.0.3.0/24 is directly connected, Ethernet0/0
L        10.0.3.19/32 is directly connected, Ethernet0/0
```


### Area 102 и получает все маршруты, кроме маршрутов до 101 R20 в 

### Фильтрация на ABR/ASBR

До фильтрации и включения OSPF:

```
R20#show ip route
Gateway of last resort is not set
      10.0.0.0/8 is variably subnetted, 2 subnets, 2 masks
C        10.0.3.0/24 is directly connected, Ethernet0/0
L        10.0.3.20/32 is directly connected, Ethernet0/0
```

```
R20#show ipv6 route
IPv6 Routing Table - default - 3 entries
C   2001:0:15:20::/64 [0/0]
     via Ethernet0/0, directly connected
L   2001:0:15:20::2/128 [0/0]
     via Ethernet0/0, receive
L   FF00::/8 [0/0]
     via Null0, receive
```

Включаем OSPF:
```
R20#show ip route
Gateway of last resort is 10.0.3.15 to network 0.0.0.0
O*E2  0.0.0.0/0 [110/1] via 10.0.3.15, 00:00:07, Ethernet0/0
      10.0.0.0/8 is variably subnetted, 6 subnets, 2 masks
O IA     10.0.1.0/24 [110/20] via 10.0.3.15, 00:00:07, Ethernet0/0
O IA     10.0.2.0/24 [110/20] via 10.0.3.15, 00:00:07, Ethernet0/0
C        10.0.3.0/24 is directly connected, Ethernet0/0
L        10.0.3.20/32 is directly connected, Ethernet0/0
O IA     10.0.5.0/24 [110/20] via 10.0.3.15, 00:00:07, Ethernet0/0
O IA     10.6.66.14/32 [110/21] via 10.0.3.15, 00:00:07, Ethernet0/0
```

Для теста добавим на R19 IP-адреса на Loopback 0:

```
R19(config)#int Loopback 0
R19(config-if)#ip address 100.0.0.19 255.255.255.255
R19(config-if)#ipv6 address 2001:1001:0:100::19/64
```

Тест, что адреса распространились:

```
Gateway of last resort is 10.0.3.15 to network 0.0.0.0

O*E2  0.0.0.0/0 [110/1] via 10.0.3.15, 00:08:38, Ethernet0/0
      10.0.0.0/8 is variably subnetted, 6 subnets, 2 masks
O IA     10.0.1.0/24 [110/20] via 10.0.3.15, 00:08:38, Ethernet0/0
O IA     10.0.2.0/24 [110/20] via 10.0.3.15, 00:08:38, Ethernet0/0
C        10.0.3.0/24 is directly connected, Ethernet0/0
L        10.0.3.20/32 is directly connected, Ethernet0/0
O IA     10.0.5.0/24 [110/20] via 10.0.3.15, 00:08:38, Ethernet0/0
O IA     10.6.66.14/32 [110/21] via 10.0.3.15, 00:08:38, Ethernet0/0
      100.0.0.0/32 is subnetted, 1 subnets
O IA     100.0.0.19 [110/31] via 10.0.3.15, 00:00:08, Ethernet0/0
```

Добавляем фильтры на R15:

```
R15(config)#ip prefix-list DENY-AREA-101 seq 5 deny 100.0.0.19/32
R15(config)#ip prefix-list DENY-AREA-101 seq 100 permit 0.0.0.0/0 le 32

R15(config)#router ospf 1
R15(config-router)#area 102 filter-list prefix DENY-AREA-101 in
R15(config-router)#end
```


Проверяем, что `100.0.0.19` исчез из таблицы:
```
R20#show ip route
Gateway of last resort is 10.0.3.15 to network 0.0.0.0

O*E2  0.0.0.0/0 [110/1] via 10.0.3.15, 00:24:16, Ethernet0/0
      10.0.0.0/8 is variably subnetted, 6 subnets, 2 masks
O IA     10.0.1.0/24 [110/20] via 10.0.3.15, 00:24:16, Ethernet0/0
O IA     10.0.2.0/24 [110/20] via 10.0.3.15, 00:24:16, Ethernet0/0
C        10.0.3.0/24 is directly connected, Ethernet0/0
L        10.0.3.20/32 is directly connected, Ethernet0/0
O IA     10.0.5.0/24 [110/20] via 10.0.3.15, 00:24:16, Ethernet0/0
O IA     10.6.66.14/32 [110/21] via 10.0.3.15, 00:24:16, Ethernet0/0
```


#### Настройка OSPF для IPv6

Включаем OSPF для IPv6 и проверяем, что маршруты распространяются:

1) Маршрут по умолчанию в 101
2) Запрет маршрута в 102

### OSPF – разделение на зоны

Все области должны быть подключены к магистральной области (area 0). Маршрутизаторы, соединяющие области, называются граничными маршрутизаторами области (ABR).

Использование зон:
- Меньший размер таблицы маршрутизации
- Снижение издержек обновления состояния каналов
- Снижение частоты расчетов SPF

Зачем вообще зоны?
Какие бывают?

### OSPF – настройка специфичных зон

R19 получил информацию о шлюзе по-умолчанию по протоколу OSPF от маршрутизатора R14. Так как R14 является ABR (граничным), а area 101, в которой находятся оба маршрутизатора, является totally stubby area, то он (R14) объявляет себя шлюзом по-умолчанию.


![img_3.png](img_3.png)



выделенный маршрутизатор (DR) как точку сбора и распространения отправленных и принятых пакетов LSA
На случай сбоя выделенного маршрутизатора (DR) также выбирается резервный назначенный маршрутизатор (BDR).

Все остальные маршрутизаторы приобретают статус маршрутизаторов DROther

