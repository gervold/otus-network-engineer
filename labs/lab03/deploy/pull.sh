#!/usr/bin/env bash

HOST=$1
USER='root'  #auth by cert
LAB_PATH='/opt/unetlab/tmp/0/ed132608-72be-4258-89f1-8c6a2b6d4621'
LAB_FILE='/opt/unetlab/labs/lab03/dhcp6.unl'

devices=(1  2  3  4  5  6)

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