#!/usr/bin/env bash
set -e

# Inputs
core_password="${1:?missing input}"
cluster_hostname="${2:?missing input}"
stackato_automation_path="${3:?missing input}"

# Get and move to the current working directory
CWD="$(dirname $0)" && cd $CWD

# Load the libraries
for lib in lib/* ; do
  if [ -f "$lib" ] ; then
    source $lib
  fi
done

message "info" "> Start the APT Cacher"
service_mgnt "apt-cacher-ng" "start"

message "info" "> Update the password of the stackato account"
change_system_password "stackato" "$core_password"

# message "info" "--> Disable SSH password authentication on the core"
# /!\ Don't do that! otherwise node will not be able to transfer SSH keys
# ssh_set_PasswordAuthentication "no"
# service_mgnt "ssh" "reload"

message "info" "> Disable SSH StrictHostKeyChecking (otherwise SSH will prompt for the check)"
ssh_set_StrictHostKeyChecking "/home/stackato/.ssh/config" "10.0.*.*" "no"

message "info" "> Kato defer the setup the core node"
kato_defer_node_rename $cluster_hostname
kato_defer_node_setup_core $cluster_hostname
