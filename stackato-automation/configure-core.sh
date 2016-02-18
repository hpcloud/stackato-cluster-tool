#!/usr/bin/env bash
set -e
set -x
# Inputs
core_password="${1:?missing input}"
cluster_hostname="${2:?missing input}"
stackato_automation_path="${3:?missing input}"
roles="${4:?missing input}"

# Get and move to the current working directory
CWD="$(dirname $0)" && cd $CWD
# Load the libraries
source load-libs.sh

message "info" "> Waiting for node to be ready"
node_ready.set_flag ".node_ready_flag"
node_ready.wait_flag ".node_ready_flag"

roles_array=($(echo $roles|tr "," " "))

message "info" "> Start the APT Cacher"
service_autostart "apt-cacher-ng"
service_mgnt "apt-cacher-ng" "start"

message "info" "> Update the password of the stackato account"
change_system_password "stackato" "$core_password"

# message "info" "--> Disable SSH password authentication on the core"
# /!\ Don't do that! otherwise new nodes will not be able to transfer SSH keys
# ssh_set_PasswordAuthentication "no"
# service_mgnt "ssh" "reload"

message "info" "> Disable SSH StrictHostKeyChecking (otherwise SSH will prompt for the check)"
ssh_set_StrictHostKeyChecking "/home/stackato/.ssh/config" "10.0.*.*" "no"

message "info" "> Setup the core node"
kato_node_rename $cluster_hostname
kato_node_setup_core $cluster_hostname

# If controller role, configure it
if [[ "${roles_array[@]/controller}" != "${roles_array[@]}" ]]; then
  message "info" "> Setup of the controller"
  controller_configure "127.0.0.1" "${core_password}"
fi
