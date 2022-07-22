#!/usr/bin/env bash

HOST=$1
USER='root'  #auth by cert
LAB_PATH='/opt/unetlab/tmp/0/12b5791b-53bd-40ba-9afd-ef0c1542b4a7'
LAB_FILE='/opt/unetlab/labs/project_work/project.unl'

#root@eve-ng:~# ls /opt/unetlab/tmp/0/12b5791b-53bd-40ba-9afd-ef0c1542b4a7
#1  10  11  12  13  14  15  16  17  2  3  4  5  6  7  8  9
devices=(1  10  11  12  13  14  15  16  17  2  3  4  5  6  7  8  9)

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