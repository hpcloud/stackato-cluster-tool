#!/usr/bin/env bash
# Setup a Stackato node
# Required parameters:
# --core-ip (e.g. 10.0.0.2)
# --cluster-hostname (e.g. myclusrer.com)
# --roles (e.g. dea,controller)

set -e
#set -x

# Get and move to the current working directory
CWD="$(dirname $0)" && cd $CWD
source load-libs.sh

function main() {
  # Get the core ip
  core_ip="$(
    while true; do
      if [ "$1" == "-c" -o "$1" == "--core-ip" ]; then shift; echo "$1"; exit;
      elif [ -z "$1" ]; then set -x; echo "Missing option --core-ip"; exit 1;
      else shift;
      fi
    done
  )"

  # Set the default values
  local core_user="stackato"
  local core_password="stackato"
  local node_user="$core_user"

  local mbus_ip="$core_ip"
  local mbus_port="4222"

  local use_proxy="false"
  local http_proxy="$core_ip"
  local http_proxy_port="8123"
  local https_proxy_port="$http_proxy_port"

  local apt_proxy="$core_ip"
  local apt_http_proxy_port="3142"
  local apt_https_proxy_port="$http_proxy_port" # Polipo because Apt cacher too old for https

  local cc_shared_dir="/mnt/controller"
  local cc_shared_dir_ip="$core_ip"
  local cc_shared_dir_user="$core_user"
  local cc_shared_dir_password="$core_password"

  declare -A ROUTER_PROPERTIES=( [prevent_x_spoofing]=false )
  local router_acl_rules="none"
  local router_acl_drop_conn="true"

  # Parse parameters
  while true; do
    case "$1" in
      -c | --core-ip           ) shift; shift;; # Already got value
      -u | --core-user         ) shift; core_user="$1";                shift;;
      -p | --core-password     ) shift; core_password="$1";            shift;;
      -n | --node-user         ) shift; node_user="$1";                shift;;
      -h | --cluster-hostname  ) shift; cluster_hostname="$1";         shift;; # Required
      -r | --roles             ) shift; roles="$1";                    shift;; # Required

      --mbus-ip                ) shift; mbus_ip="$1";                  shift;;
      --mbus-port              ) shift; mbus_port="$1";                shift;;

      --use-proxy              ) shift; use_proxy="true";;
      --http-proxy             ) shift; http_proxy="$1";               shift;;
      --http-proxy-port        ) shift; http_proxy_port="$1";          shift;;
      --https-proxy-port       ) shift; https_proxy_port="$1";         shift;;
      --apt-proxy              ) shift; apt_proxy="$1";                shift;;
      --apt-http-proxy-port    ) shift; apt_http_proxy_port="$1";      shift;;
      --apt-https-proxy-port   ) shift; apt_https_proxy_port="$1";     shift;;

      --cc-shared-dir          ) shift; cc_shared_dir="$1";            shift;;
      --cc-shared-dir-ip       ) shift; cc_shared_dir_ip="$1";         shift;;
      --cc-shared-dir-user     ) shift; cc_shared_dir_user="$1";       shift;;
      --cc-shared-dir-password ) shift; cc_shared_dir_password="$1";   shift;;

      --router-acl-rules       ) shift; router_acl_rules="$1";         shift;;
      --router-acl-drop-conn   ) shift; router_acl_drop_conn="$1";     shift;;

      -d | --debug   ) set -x; shift ;;
      -h | --help    ) usage ; exit 1 ;;
      -- ) shift; break ;;
      "" ) break ;;
      * ) echo "Invalid parameter '$1'"; usage ; exit 1 ;;
    esac
  done

  [ -z "$cluster_hostname" ] && message "error" "Missing parameter --cluster-hostname"
  [ -z "$roles" ] && message "error" "Missing parameter --roles"

  system_setup "$core_ip" "$core_user" "$core_password" \
    "/home/$node_user/.ssh/id_rsa.pub" "/home/$node_user/.ssh/authorized_keys"

  message "info" "> Waiting for node to be ready"
  wait_node_ready

  # Wait for supervisord and check config_redis is running for the kato cli
  supervisord_wait
  supervisord_check_cli_exists
  supervisord_start_process "config_redis"

  if [ "$use_proxy" == "true" ]; then
    message "info" "> Set APT and HTTP proxy"
    set_apt_proxy "$apt_proxy" "$apt_http_proxy_port" "$apt_https_proxy_port"
    get_http_proxy_envvars "$http_proxy" "$http_proxy_port" "$https_proxy_port" >> /home/stackato/.bashrc
    get_http_proxy_envvars "$http_proxy" "$http_proxy_port" "$https_proxy_port" >> /etc/default/docker
    kato_set_upstream_proxy "$http_proxy" "$http_proxy_port"
  fi

  roles_setup "$roles" "$core_ip" "$cluster_hostname" \
    "$cc_shared_dir" "$cc_shared_dir_ip" "$cc_shared_dir_user" "$cc_shared_dir_password"

  node_attach "$core_ip" "$roles" "$mbus_ip" "$mbus_port"

  roles_post_attach_setup "$roles" "$use_proxy" "$http_proxy" "$http_proxy_port" \
    "$(declare -p ROUTER_PROPERTIES)" "$router_acl_rules" "$router_acl_drop_conn"
}

function system_setup() {
  local core_ip="${1:?missing input}"
  local core_user="${2:?missing input}"
  local core_password="${3:?missing input}"
  local node_ssh_pubkey="${4:?missing input}"
  local node_authorized_keys="${5:?missing input}"

  message "info" "> Increase the Redis start script timeout"
  update_redis_timeout "300" "/home/stackato/stackato/etc/firstboot/tasks/05-wait-for-config-redis.sh"

  message "info" "> Disable SSH password authentication on the node"
  ssh_set_PasswordAuthentication "no"
  service_mgnt "ssh" "reload"

  message "info" "> Disable SSH StrictHostKeyChecking (otherwise SSH will prompt for the check)"
  ssh_set_StrictHostKeyChecking "/home/stackato/.ssh/config" "10.0.*.*" "no"

  message "info" "> Set passwordless SSH with the core node"
  ssh_copy_ssh_key "$core_ip" "$core_user" "$core_password" "$node_ssh_pubkey"

  message "info" "> Get the public key of the Core node (Passwordless ssh from the core)"
  ssh_get_remote_public_key "$core_ip" "$core_user" "$core_password" >> $node_authorized_keys

  message "info" "> Change the password"
  change_system_password "stackato" "$(openssl rand -base64 32)"
}

function roles_setup() {
  local roles="${1:?missing input}"
  local core_ip="${2:?missing input}"
  local cluster_hostname="${3:?missing input}"

  local cc_shared_dir="${4:?missing input}"
  local cc_shared_dir_ip="${5:?missing input}"
  local cc_shared_dir_user="${6:?missing input}"
  local cc_shared_dir_password="${7:?missing input}"

  local roles_array=($(echo $roles|tr "," " "))

  message "info" ">> Running the pre-attachment setup"

  message "info" "> Remove all roles"
  kato_node_remove "--all-but base primary"

  if [[ "${roles_array[@]/controller}" != "${roles_array[@]}" ]]; then
    message "info" "> Setup of the controller"
    controller_configure "$cc_shared_dir" "$cc_shared_dir_ip" \
        "$cc_shared_dir_user" "$cc_shared_dir_password"
  fi

  if [[ "${roles_array[@]/router}" != "${roles_array[@]}" ]]; then
    message "info" "> Rename the router with $cluster_hostname"
    kato_node_rename "$cluster_hostname"
  fi

  if [[ "${roles_array[@]}" != "" ]]; then
    message "info" "> Kato add roles"
    kato_role_add ${roles_array[@]}
  fi
}

function node_attach() {
  local core_ip="${1:?missing input}"
  local roles="${2:?missing input}"
  local mbus_ip="${3:?missing input}"
  local mbus_port="${4:?missing input}"

  message "info" "> Waiting for MBUS before attaching the node"
  mbus_wait_ready "$mbus_ip" "$mbus_port"

  message "info" ">> Attach the node to the core"
  kato_node_attach "$core_ip" "$roles"
}

function roles_post_attach_setup() {
  local roles="${1:?missing input}"
  local use_proxy="${2:?missing input}"
  local http_proxy="${3:?missing input}"
  local http_proxy_port="${4:?missing input}"

  eval "local -A router_properties=""${5#*=}"
  local router_acl_rules="${6:?missing input}"
  local router_acl_drop_conn="${7:?missing input}"

  local roles_array=($(echo $roles|tr "," " "))

  if [ "$use_proxy" == "true" ]; then
    message "info" "> Setup Apps HTTP Proxy"
    kato_config_set "dea_ng environment/app_http_proxy"  "http://${http_proxy}:${http_proxy_port}"
    kato_config_set "dea_ng environment/app_https_proxy" "http://${http_proxy}:${http_proxy_port}"
  fi

  message "info" ">> Postattachment setup"
  # Configure router
  if [[ "${roles_array[@]/router}" != "${roles_array[@]}" ]]; then
    message "info" "> Setup the router"
    router_properties "$(declare -p router_properties)"
    router_configure_acl "$router_acl_rules"
    router_configure_acl_drop_conn "$router_acl_drop_conn"
  fi
}

main "$@"
