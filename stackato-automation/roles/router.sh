# Set the router properties
# Call this function as showed in the following example:
# router_properties "$(declare -p your_associative_array)"
#
# The associative array can have the following keys:
#   client_inactivity_timeout
#   backend_inactivity_timeout
#   prevent_x_spoofing
#   session_affinity
#   x_frame_options
# The value will not be set for undefined keys.
# See http://docs.stackato.com/admin/server/router.html#settings for properties
#TODO: IMPROVEMENT - find a solution to avoid unsetting nounset
function router_properties() {
  set +o nounset  # Unset nounset because of the eval
  eval "local -A properties=""${1#*=}"

  local -a valid_properties=( client_inactivity_timeout backend_inactivity_timeout
                              prevent_x_spoofing session_affinity x_frame_options )

  for p in ${valid_properties[@]}; do
    if [ ! -z "${properties[$p]}" ]; then
      kato_config_set "router2g $p" "${properties[$p]}"
    fi
  done
  set -o nounset
}

# acl_rules: set to "none" if no rules
function router_configure_acl() {
  local acl_rules="${1:-none}"
  if [ ! -z "$acl_rules" -a "$acl_rules" != "none" ]; then
    kato_config_set "router2g acl/enabled" "true"
    kato_config_set "router2g acl/rules" "${acl_rules}"
  fi
}

function router_configure_acl_drop_conn() {
  local drop_conn="${1:-true}"
  if [ ! -z "${drop_conn}" ]; then
    case $drop_conn in
      true|false) kato_config_set "router2g acl/use_x_forwarded_for" "$drop_conn" ;;
      *) message "error" "Unknown ACL drop_conn value $drop_conn (should be true or false)" ;;
    esac
  fi
}

function router_configure() {
  local core_ip="${1:?missing input}"

  # If you are using a load balancer that modified headers at the HTTP level you should run
  # the following command to prevent X-Forwarded* headers from being overwritten :
  #
  # $ kato config set router2g prevent_x_spoofing false
  #
  # Please ensure that the SSL private key at /etc/ssl/private/stackato.key is copied from the primary node.

  kato_node_attach "$core_ip" "router"
}

# function router_configure() {
#   local cluster_endpoint="${1:?missing input}" # Example: my_paas.com
#   local mbus_ip="${2:?missing ip}"             # Usually the core node ip
#   local node_hostname="${3:?missing input}"    # A unique name to identify the node
#
#   # As with the Core node, you will need to run kato node rename on each router
#   # with the same API endpoint hostname. Run the following on each Router
#   kato_node_rename $cluster_endpoint
#
#   # Enable the 'router' role
#   kato_role_add "router"
#
#   # Rename the host manually after configuration to give it a unique hostname
#   echo "$node_hostname" > /etc/hostname
#   sed -i "s/127.0.1.1 $HOSTNAME/127.0.1.1 $node_hostname/" >> /etc/hosts
#   service_mgnt "hostname" "restart"
# }
#
# function router_set_terminate_ssl() {
#   local do_terminal_ssl="${1:-false}"
#
#   if [ "$do_terminal_ssl" != "true" -o "$do_terminal_ssl" != "false" ]; then
#     >&2 echo "Wrong TERMINATE_SSL value: $do_terminal_ssl (true or false)"
#     exit 1
#   fi
#
#   kato_config_set "router2g prevent_x_spoofing" "$do_terminal_ssl"
# }
