#!/usr/bin/env bash

# Usage:
# .push.sh <host ip>

HOST=$1
USER='root'  #auth by cert

LAB_PATH='/opt/unetlab/tmp/0/1766ca93-35b2-48a6-ba2b-bfe0bcfae4cb'
LAB_FILE='/opt/unetlab/labs/BGP_TS/BGP_TS.unl'

#show devices list
#root@eve-ng:/opt/unetlab/tmp/0/1766ca93-35b2-48a6-ba2b-bfe0bcfae4cb# ls
#1  2  3  4  5  6
devices=(1  2  3  4  5  6)

echo "stop all devices"
ssh $USER@$HOST "/opt/unetlab/wrappers/unl_wrapper -a stop -F $LAB_FILE -T 0"

for device in ${devices[*]}
do
  src=configs/$device/startup-config
  dst=$USER@$HOST:$LAB_TMP_PATH/$device/startup-config
  echo "copy a config from $src to ${device} device ($dst)"
  scp $src $dst
  echo "delete nvram for ${device} device"
  ssh $USER@$HOST "rm $LAB_TMP_PATH/$device/nvram_*"
  ssh $USER@$HOST "[[ -f $LAB_TMP_PATH/$device/startup.vpc ]] && cp $LAB_TMP_PATH/$device/startup-config $LAB_TMP_PATH/$device/startup.vpc"
done

echo "start all devices"
ssh $USER@$HOST "/opt/unetlab/wrappers/unl_wrapper -a start -F $LAB_FILE -T 0"

echo "export new configs"
ssh $USER@$HOST "/opt/unetlab/wrappers/unl_wrapper -a export -F $LAB_FILE -T 0"
