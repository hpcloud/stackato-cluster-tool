function router_configure() {
  local cluster_endpoint="${1:?missing input}" # Example: my_paas.com
  local mbus_ip="${2:?missing ip}"             # Usually the core node ip
  local node_hostname="${3:?missing input}"    # A unique name to identify the node

  # As with the Core node, you will need to run kato node rename on each router
  # with the same API endpoint hostname. Run the following on each Router
  kato_node_rename $cluster_endpoint

  # Enable the 'router' role
  kato_role_add "router"

  # Rename the host manually after configuration to give it a unique hostname
  echo "$node_hostname" > /etc/hostname
  sed -i "s/127.0.1.1 $HOSTNAME/127.0.1.1 $node_hostname/" >> /etc/hosts
  service_mgnt "hostname" "restart"
}

function router_set_terminate_ssl() {
  local do_terminal_ssl="${1:-false}"

  if [ "$do_terminal_ssl" != "true" -o "$do_terminal_ssl" != "false" ]; then
    >&2 echo "Wrong TERMINATE_SSL value: $do_terminal_ssl (true or false)"
    exit 1
  fi

  kato_config_set "router2g prevent_x_spoofing" "$do_terminal_ssl"
}
