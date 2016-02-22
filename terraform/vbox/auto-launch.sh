#!/bin/bash
set -o errexit

BASE_PATH=~/VirtualBox_VMs
IMAGE_NAME=stackato-v361-virtualbox.ova
INTERFACE=wlan0

set -e
# set -vx

if [ -z "$VERBOSE_IMPORT" ]; then
  VBoxManage import $BASE_PATH/$IMAGE_NAME > /tmp/vboximport.log
  DEST=/dev/null
else
  VBoxManage import $BASE_PATH/$IMAGE_NAME | tee /tmp/vboximport.log # --vmname <name>
  DEST=/dev/stdout
fi

# Virtualbox uses a 'suggested VM name' when none is provided; parse this out the get the VM name
# We could also optionally set a VM Name when importing the VM
VM_NAME="$(grep "Suggested VM name" /tmp/vboximport.log | sed s/^[^\"]*\"// | sed s/\".*//)"

# Attach to host interface "$INTERFACE" in bridged mode
VBoxManage modifyvm $VM_NAME --nic1 bridged --bridgeadapter1 "$INTERFACE" > $DEST 

# Don't use default MAC address so we can get a new IP
VBoxManage modifyvm $VM_NAME --macaddress1 auto > $DEST

# This will give you the MAC address in uppercase and without a delimiter, like 0A83BCF40D2A
MAC_ADDR=$(VBoxManage showvminfo $VM_NAME | grep -oE "MAC: [0-9A-Z]{12}" | grep -oE "[0-9A-Z]{12}")

# But we need 0A:83:BC:F4:0D:2A
MAC_ADDR=${MAC_ADDR:0:2}:${MAC_ADDR:2:2}:${MAC_ADDR:4:2}:${MAC_ADDR:6:2}:${MAC_ADDR:8:2}:${MAC_ADDR:10:2}

VBoxManage startvm $VM_NAME > $DEST
sleep 30

# Get the IP by grepping the output of arp -a
IP_ADDR=$(arp -a | grep -i $MAC_ADDR | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}")
echo $IP_ADDR
