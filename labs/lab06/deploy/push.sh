#!/usr/bin/env bash

# Usage:
# .push.sh <host ip>

HOST=$1
USER='root'  #auth by cert
LAB_TMP_PATH='/opt/unetlab/tmp/0/2c5bd2a3-4dd8-4b8a-991d-607c9cdc1d1a'  # lab id (see "lab details" from left menu)
LAB_FILE='/opt/unetlab/labs/lab06/ospf.unl'

#show devices list:
#root@eve-ng:/opt/unetlab/tmp/0/d93fe442-2cfb-4fc7-bc19-0f374a2d3962# ls
#1  10  11  12  13  14  15  16  17  18  19  2  20  21  22  23  24  25  26  27  28  29  3  30  31  32  4  5  7  8  9
devices=(1  10  11  12  13  14  15  16  17  18  19  2  20  21  22  23  24  25  26  27  28  29  3  30  31  32  4  5  7  8  9)

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
