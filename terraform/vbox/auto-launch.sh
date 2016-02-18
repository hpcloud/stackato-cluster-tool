#!/bin/bash
set -o errexit

BASE_PATH=~/VirtualBox_VMs
IMAGE_NAME=stackato-v361-virtualbox.ova
INTERFACE=wlan0

set -e
# set -vx

if [ -z "$VERBOSE_IMPORT" ]; then
  VBoxManage import $BASE_PATH/$IMAGE_NAME | tee /tmp/vboximport.log # --vmname <name>
else 
  VBoxManage import $BASE_PATH/$IMAGE_NAME > /tmp/vboximport.log
fi

VM_NAME="$(grep "Suggested VM name" /tmp/vboximport.log | sed s/^[^\"]*\"// | sed s/\".*//)"
VBoxManage modifyvm $VM_NAME --nic1 bridged --bridgeadapter1 "$INTERFACE" > /dev/null
VBoxManage modifyvm $VM_NAME --macaddress1 auto > /dev/null
MAC_ADDR=$(VBoxManage showvminfo $VM_NAME | grep -oE "MAC: [0-9A-Z]{12}" | grep -oE "[0-9A-Z]{12}")
MAC_ADDR=${MAC_ADDR:0:2}:${MAC_ADDR:2:2}:${MAC_ADDR:4:2}:${MAC_ADDR:6:2}:${MAC_ADDR:8:2}:${MAC_ADDR:10:2}
VBoxManage startvm $VM_NAME > /dev/null
sleep 30
IP_ADDR=$(arp -a | grep -i $MAC_ADDR | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}")
echo $IP_ADDR
