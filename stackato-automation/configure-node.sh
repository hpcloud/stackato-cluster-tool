#!/usr/bin/env bash
set -e
[ ! -z "$DEBUG" ] && set -x
# Inputs
core_ip="${1:?missing input}"                   # IP address of the core node
core_password="${2:?missing input}"             # Password of the Core node
cluster_hostname="${3:?missing input}"          # Hostname of the cluster (e.g. mycluster.com)
stackato_automation_path="${4:?missing input}"  # Path of the Stackato configuration scripts
roles="${5:?missing input}"                     # Comma-separated list of roles to configure
stackato_shared_cc_dir_ip="${6:-$core_ip}"      # Server IP storing the Cloud controller data
stackato_shared_cc_dir_password="${6:-$core_password}"

MBUS_IP="${core_ip}"
MBUS_PORT="4222"
STACKATO_USER="stackato"
NODE_SSH_PUBKEY="/home/stackato/.ssh/id_rsa.pub"
PROXY_HTTP_IP="${core_ip}"
PROXY_HTTP_PORT="8123"
PROXY_HTTPS_PORT="8123"

APT_PROXY_HTTP_PORT="3142" # Apt cacher server
APT_PROXY_HTTPS_PORT="${PROXY_HTTPS_PORT}" # Polipo because Apt cacher too old

declare -A ROUTER_PROPERTIES=( [prevent_x_spoofing]=false )
ROUTER_ACL_RULES=""
ROUTER_ACL_DROP_CONN=""

# Get and move to the current working directory
CWD="$(dirname $0)" && cd $CWD
source load-libs.sh

message "info" "> Increase the Redis start script timeout"
update_redis_timeout "300" "/home/stackato/stackato/etc/firstboot/tasks/05-wait-for-config-redis.sh"

message "info" "> Waiting for node to be ready"
node_ready.set_flag ".node_ready_flag"
node_ready.wait_flag ".node_ready_flag"

message "info" "> Remove all roles"
kato_node_remove "--all-but base primary"

message "info" "> Disable SSH password authentication on the node"
ssh_set_PasswordAuthentication "no"
service_mgnt "ssh" "reload"

message "info" "> Disable SSH StrictHostKeyChecking (otherwise SSH will prompt for the check)"
ssh_set_StrictHostKeyChecking "/home/stackato/.ssh/config" "10.0.*.*" "no"

message "info" "> Authorize the SSH public key of the node in the core node"
ssh_copy_ssh_key ${core_ip} ${STACKATO_USER} ${core_password} ${NODE_SSH_PUBKEY}

message "info" "> Change the password"
change_system_password "stackato" "$(openssl rand -base64 32)"

message "info" "> Use the APT Cacher on the core node"
set_apt_proxy ${core_ip} "${APT_PROXY_HTTP_PORT}" "${APT_PROXY_HTTPS_PORT}"

message "info" "> Get the public key of the Core node (Passwordless ssh from the core)"
ssh_get_remote_public_key "${core_ip}" "stackato" "${core_password}" >> /home/stackato/.ssh/authorized_keys

roles_array=($(echo $roles|tr "," " "))

message "info" ">> Running the pre-attachment setup"
if [[ "${roles_array[@]/controller}" != "${roles_array[@]}" ]]; then
  message "info" "> Setup of the controller"
  controller_configure ${stackato_shared_cc_dir_ip} ${stackato_shared_cc_dir_password}
fi

if [[ "${roles_array[@]/router}" != "${roles_array[@]}" ]]; then
  message "info" "> Rename the router with $cluster_hostname"
  kato_node_rename "$cluster_hostname"
fi

if [[ "${roles_array[@]}" != "" ]]; then
  message "info" "> Kato add roles"
  kato_role_add ${roles_array[@]}

  message "info" "> Setup the HTTP Proxy"
  kato_set_upstream_proxy "${core_ip}" "8123"
  set_bashrc_http_proxy "stackato" "${core_ip}" "8123"
fi

message "info" "> Waiting for MBUS before attaching the node"
mbus_wait_ready "${MBUS_IP}" "${MBUS_PORT}"

message "info" ">> Attach the node to the core"
kato_node_attach "${core_ip}" "$roles"

message "info" "> Setup Apps HTTP Proxy"
kato_config_set "dea_ng environment/app_http_proxy" "http://${PROXY_HTTP_IP}:${PROXY_HTTP_PORT}"
kato_config_set "dea_ng environment/app_https_proxy" "http://${PROXY_HTTP_IP}:${PROXY_HTTP_PORT}"

message "info" ">> Postattachment setup"
# Configure router
if [[ "${roles_array[@]/router}" != "${roles_array[@]}" ]]; then
  message "info" "> Setup the router"
  router_properties "$(declare -p ROUTER_PROPERTIES)"
  router_configure_acl "${ROUTER_ACL_RULES}"
  router_configure_acl_drop_conn "${ROUTER_ACL_DROP_CONN}"
fi

