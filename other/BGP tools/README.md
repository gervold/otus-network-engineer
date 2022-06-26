## BGP tools

### BGP Collectors
Это BGP соседи, которые принимают full view и никому не анонсируют (работают в passive режиме).

- Открытые
  - RIPE 
    - Описание формата хранения: https://ris.ripe.net/docs/20_raw_data_mrt.html#name-and-location
    - Файлы с RAW data ([формат MRT](https://datatracker.ietf.org/doc/html/rfc6396)): 
      - https://ris.ripe.net/docs/10_routecollectors.html
      - https://data.ris.ripe.net/rrc03/2022.06/
    - Утилиты для чтения [bgpdump](https://github.com/RIPE-NCC/bgpdump), [bgpkit-parser](https://github.com/bgpkit/bgpkit-parser)
    - RIS. Stream с BGP updates: https://ris-live.ripe.net/

  - Route Views http://www.routeviews.org/
    - Файлы с RAW data: http://archive.routeviews.org/bgpdata/2022.05/UPDATES/
  - PCH https://www.pch.net/resources/Routing_Data/
- Закрытые
  - Hurricane Electric https://bgp.he.net/AS2848
  - Qrator.Radar  https://radar.qrator.net/as2848/prefixes


### Получение информации о IX-ах, их участниках и толщине канала
https://www.peeringdb.com/


### Распространение анонсов в Интернете
- В реальном времени https://radar.qrator.net/as2848/graph#89.249.160.0/20  
- Исторические данные https://stat.ripe.net/widget/bgplay#w.resource=89.249.160.0/20

От кого распространялся анонс:  
https://stat.ripe.net/widget/routing-history#w.resource=8.8.8.0/24&w.normalise_visibility=false&w.starttime=2021-12-29T00:00:00&w.endtime=2021-12-30T00:00:00

### Рейтинги автономных систем (АС)
https://asrank.caida.org/asns  
https://radar.qrator.net/as-rating#connectivity/1  


### Настроика BGP фильтров, c примерами для разных вендоров
https://bgpfilterguide.nlnog.net/

### Освещение инцидентов безопасности, связанных с BGP
- https://bgpstream.crosswork.cisco.com/
- https://twitter.com/bgpstream
- https://twitter.com/Qrator_Radar
- Проект по детектированию Hijacks, основанный на RIS: https://bgpartemis.readthedocs.io/en/latest/


### Механизмы защиты

- защита пары <prefix, origin> (защита от Hijacks)
  - RPKI ROA
  - Проверка валидности пары https://rpki-validator.ripe.net/ui/
- защита AS_PATH (защита в том числе от Route Leaks)
  - BGPSec, ASPA
  
### Мониторинг BGP
- BMP
  - OpenSource проект поднятия разных коллекторов (в том числе и BMP) http://www.pmacct.net/  
- BFD (может использоваться не только для мониторинга BGP, но и, например, OSPF)

###
https://ftp.ripe.net/ripe/asnames/asn.txt
