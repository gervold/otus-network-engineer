#!/usr/bin/env bash

# Usage:
# .push.sh <host ip>

HOST=$1
USER='root'  #auth by cert
LAB_TMP_PATH='/opt/unetlab/tmp/0/12b5791b-53bd-40ba-9afd-ef0c1542b4a7'  # lab id (see "lab details" from left menu)
LAB_FILE='/opt/unetlab/labs/project_work/project.unl'

#show devices list:
#root@eve-ng:~# ls /opt/unetlab/tmp/0/12b5791b-53bd-40ba-9afd-ef0c1542b4a7
#1  10  11  12  13  14  2  3  4  5  6  7  8  9
devices=(1  10  11  12  13  14  2  3  4  5  6  7  8  9)

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
