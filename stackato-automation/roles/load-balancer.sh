#!/usr/bin/env bash

## Load balance from Stackato
function load_balancer_configure() {
  local cluster_endpoint="${1:?missing input}" # Example: my_paas.com
  local mbus_ip="${2:?mising input}"           # Usually the core node ip

  # The Load Balancer is the primary point of entry to the cluster. It must have
  # a public-facing IP address and take on the primary hostname for the system
  # as configured in DNS. Run the following on Load Balancer node
  kato_node_rename $cluster_endpoint

  # Attach the Helion Stackato VM to the Core node
  kato_node_attach $mbus_ip

  # Set up the node as a Load Balancer automatically
  kato_node_setup_load_balancer
}
