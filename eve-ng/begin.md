### Начало работы

Для начала работы нужно:
- Установить виртуалку (на локальный компуктер или в облако)
- Установить IOL образы маршрутизаторов
- Если нужно, то установить другие образы, в том числе qemu 

#### Дистрибутивы
https://www.eve-ng.net/index.php/download/

#### Хорошая статья про разворачивание стенда
[Строим киберполигон. Используем EVE-NG, чтобы развернуть сеть для хакерских испытаний](https://xakep.ru/2021/08/09/eve-ng/)

#### IOL
Нужно сгенерировать файл с лицензией. Для этого есть 
[python скрипт](https://gist.github.com/congto/70f9a91be7e6d90d5c33d657bf78863e).



### Сборник полезных команд для EVE-NG

https://www.eve-ng.net/index.php/faq/  

### Скрипт для управления машинками через CLI

```
/opt/unetlab/wrappers/unl_wrapper
```

Например, остановка всех машинок:
```
/opt/unetlab/wrappers/unl_wrapper -a stopall
```


### Как работать с VPC?

Назначить IP

```
VPCS> ip 10.0.0.10 255.255.255.0 10.0.0.1
Checking for duplicate address...
PC1 : 10.0.0.10 255.255.255.0 gateway 10.0.0.1
```
```
VPCS> show ip

NAME        : VPCS[1]
IP/MASK     : 10.0.0.10/24
GATEWAY     : 10.0.0.1
DNS         :
MAC         : 00:50:79:66:68:0a
LPORT       : 20000
RHOST:PORT  : 127.0.0.1:30000
MTU         : 1500
```
Тест 
```
VPCS> ping 10.0.0.10

10.0.0.10 icmp_seq=1 ttl=64 time=0.001 ms
10.0.0.10 icmp_seq=2 ttl=64 time=0.001 ms
10.0.0.10 icmp_seq=3 ttl=64 time=0.001 ms
10.0.0.10 icmp_seq=4 ttl=64 time=0.001 ms
10.0.0.10 icmp_seq=5 ttl=64 time=0.001 ms
```

Посмотреть ARP таблицу:
```
VPCS> arp

aa:bb:cc:80:b0:00  10.0.0.1 expires in 40 seconds
```