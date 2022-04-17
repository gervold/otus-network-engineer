#!/usr/bin/env bash

HOST=$1
USER='root'  #auth by cert
LAB_PATH='/opt/unetlab/tmp/0/d93fe442-2cfb-4fc7-bc19-0f374a2d3962'

#root@eve-ng:/opt/unetlab/tmp/0/d93fe442-2cfb-4fc7-bc19-0f374a2d3962# ls
#1  10  11  12  13  14  15  16  17  18  19  2  20  21  22  23  24  25  26  27  28  29  3  30  31  32  4  5  7  8  9
devices=(1  10  11  12  13  14  15  16  17  18  19  2  20  21  22  23  24  25  26  27  28  29  3  30  31  32  4  5  7  8  9)

for device in ${devices[*]}
do
  src=configs/$device/startup-config
  dst=$USER@$HOST:$LAB_PATH/$device/startup-config
  echo "copying a config from $src to ${device} device ($dst)"
  scp $src $dst
done