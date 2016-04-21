CMD_NATNETWORK="natnetwork"

# Add a nat network
function vbox_natnetwork_add() {
  local name="${1:?missing input}"
  local network="${2:?missing input}"
  local dhcp="${3:?missing input}"
  
  local cmd="$CMD_NATNETWORK add"
  local cmd_opts="--netname $name --network $network --dhcp $dhcp"

  vbox_runcmd "$cmd" "$cmd_opts"
}

# Remove a nat network
function vbox_natnetwork_remove() {
  local name="${1:?missing input}"

  local cmd="$CMD_NATNETWORK remove"
  local cmd_opts="--netname $name"

  vbox_runcmd "$cmd" "$cmd_opts"
}

# Add an IPv4 port forward rule to a nat network
function vbox_natnetwork_portforward4_add() {
  local name="${1:?missing input}"
  local rule="${2:?missing input}"

  local cmd="$CMD_NATNETWORK modify"
  local cmd_opts="--port-forward-4 $rule"

  vbox_runcmd "$cmd" "$cmd_opts"
}

# Delete an IPv4 port forward rule from a nat network
function vbox_natnetwork_portforward4_delete() {
  local name="${1:?missing input}"
  local rule_name="${2:?missing input}"

  local cmd="$CMD_NATNETWORK modify"
  local cmd_opts="--netname $name --port-forward-4 delete $rule_name"
}

