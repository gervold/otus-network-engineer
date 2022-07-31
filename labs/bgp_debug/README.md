### Лабораторная работа по отладке в BGP

1 - Все маршутизаторы и их интерфейсы должны быть доступны между собой  
2 - AS100 не должна быть транзинтной  
3 - R1 не должен быть транзитным  
4 - R4 и R5 должны балансировать исходящий трафик  
5 - R1 балансирует исходящий трафик  
6 - Основной вход для входящего трафика в AS100 через маршрутизатор R5.  
7 - Входящий трафик на R1 должен приходить через R3. Использование as-prepend запрещено  
8 - Настройки должны быть оптимизированы  
9 - маршруты должны быть оптимизированы  
10 - BGP в AS100 должен работать максимально стабильно  


#### 1. Все маршутизаторы и их интерфейсы должны быть доступны между собой

Пытаемся разобраться, что у нас есть
```
show ip bgp summary
show ip bgp
```

R4:
```
ip bgp-community new-format
```
Получается:
```
community 100:666
```

R5:
```
show ip access-list FIREWALL
```

Настройка BGP соседства на R5
```
ip access-list extended FIREWALL
15 permit tcp any any eq 179
```
Проверка: `show ip bgp summary`

R6:
Видим, что в конфиге есть адрес на Loopback, но он не распространяется.
```
int Loopback 0
no ip address 100.100.100.100 255.255.255.0
ip address 100.100.100.100 255.255.255.255
```
Проверка `show ip bgp summary`

Есть route-map, которая выставляет в 0 LP для R4
тоесть исходящий будет идти через R5.

```
ping 100.100.100.100 source 200.200.200.200
```

`neighbor X.X.X.X update-source Loopback1`

#### 2 - AS100 не должна быть транзинтной  
R4 – принимает все от R2 и R3 и отдает только свои сети.
R5 – принимает все от R2 и R3 и отдает только свои сети.
Свои сети это 100.100.100.100 и 10.xxx?

R4>
```
ip as-path access-list 1 permit ^$
ip as-path access-list 1 deny .*

neighbor 50.0.0.3 filter-list 1 out
neighbor 50.0.3.2 filter-list 1 out
```
R5 - аналогично


#### 3 - R1 не должен быть транзитным  
аналогично
```
ip as-path access-list 1 permit ^$
ip as-path access-list 1 deny .*

neighbor 100.0.0.2 filter-list 1 out
neighbor 100.0.1.3 filter-list 1 out
```

#### 4 - R4 и R5 должны балансировать исходящий трафик  
Может показаться, что они и так балансируют – линка два, но выбирается как best path только один.
Поэтому
```
maximum-paths 2
```
Длина одинаковая, но провайдеры – разные (не выполняется условие со слайда, про одного оператора).
```
bgp bestpath as-path multipath-relax
```
Проверка: `show ip route`



#### 5 - R1 балансирует исходящий трафик  
Аналогично.

Префикс не попадает в таблицу LocRIB 
Не отображается show ip bgp (и тем более соседям).
Это значит, что что-то с префиксом не так.
Замечаем, что неправильная маска у лупбека.
```
interface Loopback0
 no shutdown
 ip address 100.100.100.100 255.255.255.0
```

Дальше:
```
maximum paths 2
bgp bestpath as-path multipath-relax
```

#### 6 - Основной вход для входящего трафика в AS100 через маршрутизатор R5.  
BGP выберет кратчайший маршрут, поэтому можно его удлинить.

Добавляем препенд.
```
route-map AS-PREP permit 10
set as-path prepend 100 100 100 100 100

и применяем к соседу:

neighbor 50.0.0.3 route-map AS-PREP out
neighbor 50.0.3.2 route-map AS-PREP out
```

На R4 стоит blackhole community. Если R3 принимает апдейт с этим комьюнити, то он блокирует апдейт,
поэтому анонс отбрасывается ingress политикой и не заносится в LocRIB.

Для исходящих сначала filter-list, а потом уже route-map применяются

route-map и filter-list по умолчанию блокируют анонсы (если указаны, но не настроены никак)
prefix-list и distribute-list - пропустят любой анонс


#### 7 - Входящий трафик на R1 должен приходить через R3. Использование as-prepend запрещено  
Community

R2 – маленький local preference
R3 – большой local preference

тогда будут выбираться маршруты идущие через R5

Local Preference ставится у провайдеров через Community, либо руками.

Настройка отправки:
```
neighbor 50.0.0.3 send-community
neighbor 50.0.0.3 route-map backhole out

route-map backhole permit 10
 set community 100:666
```

Настройка приема:
```
neighbor 50.0.0.4 route-map backhole in

ip bgp-community new-format
ip community-list 1 deny 100:666

route-map backhole permit 10
 match community 1
```

#### 8 - Настройки должны быть оптимизированы  

Настроить один из R4, R5, R6 в качестве RR, чтобы только один апдейт раздавался маршрутизаторам.


#### 9 - маршруты должны быть оптимизированы  

Аггрегация префиксов в 10.0.0.0/22.
Отдавать его одним (суммарным) префиксом выше.
На обоих нужно будет настроить суммаризацию.

#### 10 - BGP в AS100 должен работать максимально стабильно  
Настройка iBGP на лупбеках + делать update source
И настройка внутри зоны через IGRP протокол, чтобы внутри зоны была связность.
Сейчас там настроено соседство много где.




![img.png](img.png)



#### Разное

```
clear ip bgp *

ip bgp-community new-format

sh run | s bgp - секция
sh run | i bgp - вхождения
sh run | b bgp - начинается с и ниже

show ip bgp neighbords 100.0.0.2 advertised-routes

# передачи Default Route нижестоящему маршрутизатору
neighbor 10.0.10.1 default-originate

# анонс вникуда
ip route 100.100.100.100 255.255.255.255 null 0

```