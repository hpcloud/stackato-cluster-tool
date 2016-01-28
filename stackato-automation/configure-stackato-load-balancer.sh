#!/usr/bin/env bash
: ${CLUSTER_ENDPOINT:="$1"} # Example: my_paas.com
: ${MBUS_IP:="$2"}          # Usually the core node ip

: ${KATO_BIN:=kato}

# The Load Balancer is the primary point of entry to the cluster. It must have
# a public-facing IP address and take on the primary hostname for the system
# as configured in DNS. Run the following on Load Balancer node
$KATO_BIN node rename $CLUSTER_ENDPOINT

# Attach the Helion Stackato VM to the Core node
$KATO_BIN node attach $MBUS_IP

# Set up the node as a Load Balancer automatically
$KATO_BIN node setup load_balancer --force
