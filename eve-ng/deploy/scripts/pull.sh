#!/usr/bin/env bash

HOST=$1
USER='root'  #auth by cert
LAB_PATH='/opt/unetlab/tmp/0/d93fe442-2cfb-4fc7-bc19-0f374a2d3962'
LAB_FILE='/opt/unetlab/labs/lab04/ip.unl'

#root@eve-ng:/opt/unetlab/tmp/0/d93fe442-2cfb-4fc7-bc19-0f374a2d3962# ls
#1  10  11  12  13  14  15  16  17  18  19  2  20  21  22  23  24  25  26  27  28  29  3  30  31  32  4  5  7  8  9
devices=(1  10  11  12  13  14  15  16  17  18  19  2  20  21  22  23  24  25  26  27  28  29  3  30  31  32  4  5  7  8  9)

echo "export configs"
ssh $USER@$HOST "/opt/unetlab/wrappers/unl_wrapper -a export -F $LAB_FILE -T 0"

echo "wipe and start all devices. It's need for saving fresh startup-configs"
ssh $USER@$HOST "/opt/unetlab/wrappers/unl_wrapper -a wipe -F $LAB_FILE -T 0"
ssh $USER@$HOST "/opt/unetlab/wrappers/unl_wrapper -a start -F $LAB_FILE -T 0"

for device in ${devices[*]}
do
  src=$USER@$HOST:$LAB_PATH/$device/startup-config
  dst=configs/$device/.
  echo "copying a config for ${device} device from $src to "
  mkdir -p "configs/$device"
  scp $src $dst
done