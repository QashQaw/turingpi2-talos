#!/bin/sh
TPI='/usr/bin/tpi'
SLEEP='/bin/sleep 2'
IMAGE='/mnt/sdcard/talos-1.6.6_rk1-arm64.raw'

echo "Starting the script - poweroff all nodes"
$TPI power off
$SLEEP
echo "flashing node 1"
$TPI flash --node 1 -i $IMAGE
$SLEEP
echo " Finished flashing node 1 - Power it on before starting flashing node 2"
$SLEEP
$TPI power on -n 1
$SLEEP
echo "flashing node 2"
$TPI flash --node 2 -i $IMAGE
$SLEEP
echo "flashing node 3"
$TPI flash --node 3 -i $IMAGE
$SLEEP
echo "flashing node 4"
$TPI flash --node 4 -i $IMAGE
$SLEEP
echo " Finished with Flashing the nodes"
$SLEEP
echo " Will now power on the other 3 nodes"
$TPI power on -n 2
$TPI power on -n 3
$TPI power on -n 4
$SLEEP
echo " End of the script "
