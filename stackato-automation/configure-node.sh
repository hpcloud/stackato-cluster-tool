#!/usr/bin/env bash
set -e

# Inputs
core_ip="${1:?missing input}"                   # IP address of the core node
core_password="${2:?missing input}"             # Password of the Core node
cluster_hostname="${3:?missing input}"          # Hostname of the cluster (e.g. mycluster.com)
stackato_automation_path="${4:?missing input}"  # Path of the Stackato configuration scripts
roles="${5:?missing input}"                     # Comma-separated list of roles to configure
stackato_shared_cc_dir_ip="${6:-$core_ip}"      # Server IP storing the Cloud controller data
stackato_shared_cc_dir_password="${6:-$core_password}"

# Get and move to the current working directory
CWD="$(dirname $0)" && cd $CWD
# Load the libraries
source load-libs.sh

message "info" "> Increase the Redis start script timeout"
upgrade_redis_timeout "300" "/home/stackato/stackato/etc/firstboot/tasks/05-wait-for-config-redis.sh"

message "info" "> Waiting for node to be ready"
node_ready.set_flag ".node_ready_flag"
node_ready.wait_flag ".node_ready_flag"

message "info" "> Remove all roles"
kato_node_remove "--all"

message "info" "> Disable SSH password authentication on the node"
ssh_set_PasswordAuthentication "no"
service_mgnt "ssh" "reload"

message "info" "> Change the password"
change_system_password "stackato" "$(openssl rand -base64 32)"

message "info" "> Use the APT Cacher on the core node"
set_apt_proxy ${core_ip} "3142"

message "info" "> Get the public key of the Core node (Passwordless ssh from the core)"
ssh_get_remote_public_key "${core_ip}" "stackato" "${core_password}" >> /home/stackato/.ssh/authorized_keys

roles_array=($(echo $roles|tr "," " "))

# Configure controller
if [[ "${roles_array[@]/controller}" != "${roles_array[@]}" ]]; then
  # Delete the role from the array
  new_array=${roles_array[@]/controller}
  unset roles_array
  roles_array=${new_array[@]}

  message "info" "> Setup of the controller"
  controller_configure ${stackato_shared_cc_dir_ip} ${stackato_shared_cc_dir_password}
fi

# Configure router
if [[ "${roles_array[@]/router}" != "${roles_array[@]}" ]]; then
  message "info" "> TODO Configuring router role"
  # Delete the role from the array
  new_array=${roles_array[@]/controller}
  unset roles_array
  roles_array=${new_array[@]}

  message "info" "> Done configuring router role"
fi

# Configure other roles
if [[ "${roles_array[@]}" != "" ]]; then
  message "info" "> Kato add roles"
  kato_role_add ${roles_array[@]}

  message "info" "> Setup the HTTP Proxy"
  kato_set_upstream_proxy "${core_ip}" "8123"
  set_bashrc_http_proxy "stackato" "${core_ip}" "8123"
fi

message "info" "> Kato defer attach the node to the core"
kato_defer_attach_node "${core_ip}" "stackato" "${core_password}"
