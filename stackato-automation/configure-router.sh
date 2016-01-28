#!/usr/bin/env bash
: ${CLUSTER_ENDPOINT:="$1"} # Example: my_paas.com
: ${MBUS_IP:="$2"}          # Usually the core node ip
: ${NODE_HOSTNAME:="$3"}    # A unique name to identify the node

: ${KATO_BIN:=kato}

# As with the Core node, you will need to run kato node rename on each router
# with the same API endpoint hostname. Run the following on each Router
$KATO_BIN node rename $CLUSTER_ENDPOINT

# Enable the 'router' role and attach the node to the cluster
$KATO_BIN node attach -e router $MBUS_IP

# Rename the host manually after configuration to give it a unique hostname
echo "$NODE_HOSTNAME" > /etc/hostname
sed -i "s/127.0.1.1 $HOSTNAME/127.0.1.1 $NODE_HOSTNAME/" >> /etc/hosts
sudo service hostname restart
