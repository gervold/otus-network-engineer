## BGP. Фильтрация

### Цель:
- Настроить фильтрацию для офисе Москва
- Настроить фильтрацию для офисе С.-Петербург

### Описание/Пошаговая инструкция выполнения домашнего задания:
В этой  самостоятельной работе мы ожидаем, что вы самостоятельно:

- Настроить фильтрацию в офисе Москва так, чтобы не появилось транзитного трафика(As-path).
- Настроить фильтрацию в офисе С.-Петербург так, чтобы не появилось транзитного трафика(Prefix-list).
- Настроить провайдера Киторн так, чтобы в офис Москва отдавался только маршрут по умолчанию.
- Настроить провайдера Ламас так, чтобы в офис Москва отдавался только маршрут по умолчанию и префикс офиса С.-Петербург.
- Все сети в лабораторной работе должны иметь IP связность.


### Общая информация

<details>

<summary>Минимальная настройка</summary>

см. лабу 9.

</details>

<details>

<summary>Полезные команды</summary>

см. лабу 9.

```
clear ip bgp *
show ip bgp summary
show ip bgp 
show ip route bgp
```

</details>

<details>

<summary>Общая информация</summary>

Основные механизмы:
- prefix-list – один из основных инструментов для работы с префиксами в BGP
- distribute-list – "аналог ACL, но не так удобно" (c)
- filter-list – удобно делать по `as-path`
- route-map – можно комбинировать предыдущие три механизма

Нельзя одновременно использовать prefix-list и distribution-list, они взаимноисключающие. 

</details>



### Выполнение


### Устранение транзитного трафика

Есть два основных способа:
- фильтрация по `as-path` (когда мы не являемся транзитной АС)
- фильтрация по набору префиксов (подходит для транзитных АС)

### Устранение транзитного трафика в Москве

В текущей схеме транзитного трафика – нет. <br>
Все равно напишем на R14 и R15 правила для предотвращения транзита в будущем:

```
R15(config)#ip as-path access-list 1 permit ^$
R15(config)#ip as-path access-list 1 deny .*

R15(config)#router bgp 1001
R15(config-router)#neighbor 30.0.0.21 filter-list 1 out
```

_Демонстрация этого варианта фильтрации была на семинаре по BGP._

### Устранение транзитного трафика в СПБ

Тут транзитного трафика тоже нет.<br>
Разрешим анонсировать только клиенские сети: 
```
R18(config)#ip prefix-list PL-NO-TRANSIT seq 5 permit 200.0.0.0/24
R18(config)#ip prefix-list PL-NO-TRANSIT seq 10 permit 200.0.1.0/24

R18(config)#router bgp 2042
R18(config-router)#neighbor 52.0.1.24 prefix-list PL-NO-TRANSIT out
R18(config-router)#neighbor 52.0.2.26 prefix-list PL-NO-TRANSIT out
```

Эти правила полезны на случай, если появится второй провайдер (например стык с Ламас).


### Передача default от Киторн в сторону Москвы

До фильтрации было:
```
R14#show ip bgp

     Network          Next Hop            Metric LocPrf Weight Path
 *>  100.0.0.0/24     0.0.0.0                  0         32768 i
 r>i 100.0.1.0/24     15.15.15.15             20    300      0 i
 *   101.101.101.101/32
                       101.0.0.22               0             0 101 i
 *>i                  15.15.15.15              0    300      0 301 101 i
 *   200.0.0.0        101.0.0.22                             0 101 301 520 2042 i
 *>i                  15.15.15.15              0    300      0 301 520 2042 i
 *   200.0.1.0        101.0.0.22                             0 101 301 520 2042 i
 *>i                  15.15.15.15              0    300      0 301 520 2042 i
```

Видно присутствие _нескольких_ маршрутов от Киторн (AS101).

Прокидываем дефолт, остальное запрещаем: 
```
R22(config)#ip prefix-list PL-DEFAULT deny 0.0.0.0/0

R22(config)#router bgp 101
R22(config-router)#neighbor 101.0.0.14 default-originate
R22(config-router)#neighbor 101.0.0.14 prefix-list PL-DEFAULT out
```
```
R22(config)#ipv6 prefix-list PL-DEFAULT-IPV6 seq 5 deny ::/0

R22(config)#router bgp 101
R22(config-router)#neighbor 2001:101:14:22::1 default-originate
R22(config-router)#neighbor 2001:101:14:22::1 prefix-list PL-DEFAULT-IPV6 out
```

После посылки дефолта и фильтрации видим единственный `0.0.0.0` от AS101:
```
R14#show ip bgp

     Network          Next Hop            Metric LocPrf Weight Path
 *>  0.0.0.0          101.0.0.22                             0 101 i
 *>  100.0.0.0/24     0.0.0.0                  0         32768 i
 r>i 100.0.1.0/24     15.15.15.15             20    300      0 i
 *>i 101.101.101.101/32
                       15.15.15.15              0    300      0 301 101 i
 *>i 200.0.0.0        15.15.15.15              0    300      0 301 520 2042 i
 *>i 200.0.1.0        15.15.15.15              0    300      0 301 520 2042 i
```

```
R14#show ip route bgp
Gateway of last resort is 101.0.0.22 to network 0.0.0.0

B*    0.0.0.0/0 [20/0] via 101.0.0.22, 00:04:30
      101.0.0.0/8 is variably subnetted, 3 subnets, 2 masks
B        101.101.101.101/32 [200/0] via 15.15.15.15, 00:37:40
B     200.0.0.0/24 [200/0] via 15.15.15.15, 00:31:56
B     200.0.1.0/24 [200/0] via 15.15.15.15, 00:31:56
```


### Передача default от Ламас в сторону Москвы

Аналогично передадим default от R21 в сторону R15.

Видим, что в поступающих на R15 маршрутах есть сети Киторна (`101.101.101.101`):

```
R15#show ip bgp
BGP table version is 7, local router ID is 30.0.0.15
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal,
              r RIB-failure, S Stale, m multipath, b backup-path, f RT-Filter,
              x best-external, a additional-path, c RIB-compressed,
Origin codes: i - IGP, e - EGP, ? - incomplete
RPKI validation codes: V valid, I invalid, N Not found

     Network          Next Hop            Metric LocPrf Weight Path
 r>i 0.0.0.0          14.14.14.14              0    100      0 101 i
 r>i 100.0.0.0/24     14.14.14.14              0    100      0 i
 *>  100.0.1.0/24     10.0.1.12               20         32768 i
 *>  101.101.101.101/32
                       30.0.0.21                              0 301 101 i
 *>  200.0.0.0        30.0.0.21                              0 301 520 2042 i
 *>  200.0.1.0        30.0.0.21                              0 301 520 2042 i

```

```
R15#show ip route bgp

Gateway of last resort is 30.0.0.21 to network 0.0.0.0

      101.0.0.0/32 is subnetted, 1 subnets
B        101.101.101.101 [20/0] via 30.0.0.21, 00:42:13
B     200.0.0.0/24 [20/0] via 30.0.0.21, 00:41:52
B     200.0.1.0/24 [20/0] via 30.0.0.21, 00:41:52
```

Пропишем что бы R21 отдавал соседу R15 маршрут по умолчанию и фильтровал все префиксы, кроме содержащий в начале пути AS2042 (СПБ):

```
ip as-path access-list 1 permit _2042$
ip as-path access-list 1 deny .*

router bgp 301
neighbor 30.0.0.15 default-originate
neighbor 30.0.0.15 filter-list 1 out
```

Теперь поступают только дефолт и Питерские префиксы. Сети Киторна (`101.101.101.101`) были отфильтрованы:

```
R15#show ip route bgp

Gateway of last resort is 30.0.0.21 to network 0.0.0.0

B     200.0.0.0/24 [20/0] via 30.0.0.21, 00:49:06
B     200.0.1.0/24 [20/0] via 30.0.0.21, 00:49:06
```

```
R15#show ip bgp
BGP table version is 9, local router ID is 30.0.0.15

     Network          Next Hop            Metric LocPrf Weight Path
 r>  0.0.0.0          30.0.0.21                              0 301 i
 r>i 100.0.0.0/24     14.14.14.14              0    100      0 i
 *>  100.0.1.0/24     10.0.1.12               20         32768 i
 *>  200.0.0.0        30.0.0.21                              0 301 520 2042 i
 *>  200.0.1.0        30.0.0.21                              0 301 520 2042 i
```


### Попинговать

Проверим, что клиентские сети работают:

```
PC1 : 100.0.1.7 255.255.255.0 gateway 100.0.1.1

PC1 : 2001:1001:0:101::7/64

VPCS> ping 200.0.0.8

84 bytes from 200.0.0.8 icmp_seq=1 ttl=56 time=1.892 ms
84 bytes from 200.0.0.8 icmp_seq=2 ttl=56 time=1.691 ms
84 bytes from 200.0.0.8 icmp_seq=3 ttl=56 time=2.111 ms
^C
VPCS> ping 200.0.1.11

84 bytes from 200.0.1.11 icmp_seq=1 ttl=57 time=2.973 ms
84 bytes from 200.0.1.11 icmp_seq=2 ttl=57 time=1.601 ms
^C
```

```
Checking for duplicate address...
PC1 : 200.0.1.11 255.255.255.0 gateway 200.0.1.1

PC1 : 2001:2042:10:11::2/64

VPCS> ping 100.0.0.10

84 bytes from 100.0.0.10 icmp_seq=1 ttl=57 time=3.408 ms
84 bytes from 100.0.0.10 icmp_seq=2 ttl=57 time=1.614 ms
84 bytes from 100.0.0.10 icmp_seq=3 ttl=57 time=1.602 ms
^C
VPCS> ping 100.0.1.7

84 bytes from 100.0.1.7 icmp_seq=1 ttl=56 time=8.502 ms
84 bytes from 100.0.1.7 icmp_seq=2 ttl=56 time=1.731 ms
^C
```

<details>

<summary> и трейс </summary>

```
VPCS> trace 100.0.1.7 -P 6
trace to 100.0.1.7, 8 hops max (TCP), press Ctrl+C to stop
 1   200.0.1.1   0.187 ms  0.133 ms  0.108 ms
 2   10.0.2.9   0.337 ms  0.215 ms  0.263 ms
 3   10.0.0.18   0.509 ms  0.333 ms  0.292 ms
 4   52.0.1.24   0.496 ms  0.382 ms  0.322 ms
 5   52.0.0.21   0.648 ms  0.511 ms  0.446 ms
 6   30.0.0.15   0.549 ms  0.570 ms  0.520 ms
 7   10.0.1.12   0.806 ms  0.729 ms  0.764 ms
 8   100.0.1.7   2.242 ms  0.960 ms  0.955 ms
```

</details>