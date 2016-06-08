# Setup a Stackato node
function usage() {
  >&2 echo "
      $0 OPTIONS

      Required options:

      -c | --core-ip           : IP address of the core node (used 127.0.0.1 when running on the Core node
      -h | --cluster-hostname  : Stackato cluster hostname (e.g. mycluster.com)
      -r | --roles             : comma-separated list of Stackato roles

      Optional options:

      -u | --core-user         : Username to SSH on the core node
      -p | --core-password     : Password to SSH on the core node
      -n | --node-user         : Stackato username

      --mbus-ip                : IP of the mbus server
      --mbus-port              : Port of the mbus server

      --start-apt-cacher       : Start an APT cacher on the node

      --use-proxy              : Use an HTTP/HTTPS proxy on the node
      --http-proxy             : Address of the HTTP proxy server
      --https-proxy            : Address of the HTTPS proxy server
      --apt-http-proxy         : Address of the APT proxy server for HTTP requests
      --apt-https-proxy        : Address of the APT proxy server for HTTPS requests

      --cc-shared-dir          : Path of the shared directory between Cloud Controller
      --cc-shared-dir-ip       : IP of the server hosting the shared directory
      --cc-shared-dir-user     : User to connect to the shared directory
      --cc-shared-dir-password : Password to connect to the shared directory

      --router-acl-rules       : Stackato router ACL rules
      --router-acl-drop-conn   : Stacakto router ACL drop connection

      -d | --debug             : Run this script in debug mode
      -h | --help              : Print thie help message
  "
}

function setup_node() {
  ########################## Parse parameters ##################################
  while [ $# -gt 0 ]; do
    case "$1" in
      -c | --core-ip           ) shift; core_ip="$1";                  shift;; # Required
      -u | --core-user         ) shift; core_user="$1";                shift;;
      -p | --core-password     ) shift; core_password="$1";            shift;;
      -n | --node-user         ) shift; node_user="$1";                shift;;
      -h | --cluster-hostname  ) shift; cluster_hostname="$1";         shift;; # Required
      -r | --roles             ) shift; roles="$1";                    shift;; # Required

      --mbus-ip                ) shift; mbus_ip="$1";                  shift;;
      --mbus-port              ) shift; mbus_port="$1";                shift;;

      --start-apt-cacher       ) shift; start_apt_cacher="true";       shift;;

      --use-proxy              ) shift; use_proxy="true";;
      --http-proxy             ) shift; http_proxy="$1";               shift;;
      --https-proxy            ) shift; https_proxy="$1";               shift;;
      --apt-http-proxy         ) shift; apt_http_proxy="$1";           shift;;
      --apt-https-proxy        ) shift; apt_https_proxy="$1";          shift;;

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

  [ -z "${core_ip:-}" ]          && message "error" "Missing parameter --core-ip. See $0 --help"
  [ -z "${cluster_hostname:-}" ] && message "error" "Missing parameter --cluster-hostname. See $0 --help"
  [ -z "${roles:-}" ]            && message "error" "Missing parameter --roles. See $0 --help"

  ####################### Set the default values ###############################
  local core_user="${core_user:-stackato}"
  local core_password="${core_password:-stackato}"
  local node_user="${node_user:-$core_user}"

  local mbus_ip="${mbus_ip:-$core_ip}"
  local mbus_port="${mbus_port:-4222}"

  local start_apt_cacher="${start_apt_cacher:-false}"

  # Proxy settings
  local use_proxy="${use_proxy:-false}"
  if [ "$use_proxy" == "true" ]; then
    local http_proxy="${http_proxy:?missing input}"
    local https_proxy="${https_proxy:-$http_proxy}"

    local apt_http_proxy="${apt_http_proxy:-$http_proxy}"
    local apt_https_proxy="${apt_https_proxy_port:-$https_proxy}" # Polipo because Apt cacher too old for https
  fi

  # Cloud Controller settings
  local cc_shared_dir="${cc_shared_dir:-/mnt/controller}"
  local cc_shared_dir_ip="${cc_shared_dir_ip:-$core_ip}"
  local cc_shared_dir_user="${cc_shared_dir_user:-$core_user}"
  local cc_shared_dir_password="${cc_shared_dir_password:-$core_password}"

  # Router settings
  declare -A ROUTER_PROPERTIES=( [prevent_x_spoofing]=false )
  local router_acl_rules="${router_acl_rules:-none}"
  local router_acl_drop_conn="${router_acl_drop_conn:-true}"

  ############################ Start provisioning ##############################
  ##############################################################################
  fstab_cleanup
  sudo_set_passwordless "$node_user" "ALL=(ALL) NOPASSWD:ALL"

  if [ "$start_apt_cacher" == "true" ]; then
    message "info" "> Start the APT Cacher"
    service_autostart "apt-cacher-ng"
    service_mgnt "apt-cacher-ng" "start"
  fi

  message "info" "> Waiting for node to be ready"
  wait_node_ready

  system_setup "$roles" "$core_ip" "$core_user" "$core_password" \
    "/home/$node_user/.ssh/id_rsa.pub" "/home/$node_user/.ssh/authorized_keys"

  if [ "$use_proxy" == "true" ]; then
    message "info" "> Set APT and HTTP proxy"
    [ -z "$http_proxy" ] && message "error" "Missing parameter --http-proxy. See $0 --help"
    set_apt_proxy "$apt_http_proxy" "$apt_https_proxy"
    get_http_proxy_envvars "$http_proxy" "$https_proxy" >> /home/stackato/.bashrc
    get_http_proxy_envvars "$http_proxy" "$https_proxy" >> /etc/default/docker
    service_mgnt "docker" "restart"
  fi

  message "info" "Start config_redis before using the kato cli"
  supervisord_wait
  supervisord_check_cli_exists
  supervisord_start_process "config_redis"

  roles_setup "$roles" "$core_ip" "$cluster_hostname" \
    "$cc_shared_dir" "$cc_shared_dir_ip" "$cc_shared_dir_user" "$cc_shared_dir_password"

  if [ "${roles#core}" == "${roles}" ]; then
    message "info" "> Waiting for the MBUS server before attaching the node"
    mbus_wait_ready "$mbus_ip" "$mbus_port"
    message "info" "> Pre-attachment setup"
    roles_pre_attach_setup "$core_ip" "$core_user" "$roles"
    message "info" "> Attaching the node to the core node on $core_ip"
    node_attach "$core_ip" "$roles" "$mbus_ip" "$mbus_port"
  fi

  roles_post_attach_setup "$roles" "$use_proxy" "$http_proxy" "$https_proxy"\
    "$(declare -p ROUTER_PROPERTIES)" "$router_acl_rules" "$router_acl_drop_conn"
}

# Setup the node at the system level (passwordless sudo, ssh, etc)
#
#   @core_ip: ip address of the Core node
#   @core_user: user to SSH into the Core node
#   @core_password: password to SSH into the Core node
#   @node_ssh_pubkey: path of the SSH public of the node
#   @node_authorized_keys: path of the authorized_keys file of the node
#
function system_setup() {
  local roles="${1:?missing input}"
  local core_ip="${2:?missing input}"
  local core_user="${3:?missing input}"
  local core_password="${4:?missing input}"
  local node_ssh_pubkey="${5:?missing input}"
  local node_authorized_keys="${6:?missing input}"

  local roles_array=($(echo $roles|tr "," " "))

  message "info" "> System setup"

  # Core system setup
  if [[ "${roles_array[@]/core}" != "${roles_array[@]}" ]]; then
    message "info" ">> Update the password of the stackato account"
    change_system_password "stackato" "$core_password"
  # Node system setup
  else
    message "info" ">> Increase the Redis start script timeout"
    update_redis_timeout "300" "/home/stackato/stackato/etc/firstboot/tasks/05-wait-for-config-redis.sh"

    message "info" ">> Set passwordless SSH with the core node"
    ssh_copy_ssh_key "$core_ip" "$core_user" "$core_password" "$node_ssh_pubkey"

    message "info" ">> Get the public key of the Core node (Passwordless ssh from the core)"
    ssh_get_remote_public_key "$core_ip" "$core_user" "$core_password" >> $node_authorized_keys

    message "info" ">> Set a random password on the node"
    change_system_password "stackato" "$(openssl rand -base64 32)"
  fi

  message "info" ">> Disable SSH StrictHostKeyChecking (otherwise SSH will prompt for the check)"
  ssh_set_StrictHostKeyChecking "/home/stackato/.ssh/config" "10.0.*.*" "no"

  message "info" ">> Disable SSH password authentication on the node"
  ssh_set_PasswordAuthentication "no"

  message "info" ">> Allow SSH password login only from the cluster network"
  ssh_add_match "/etc/ssh/sshd_config" "User $core_user Address 10.0.0.0/16"
  ssh_add_match_option "/etc/ssh/sshd_config" "User $core_user Address 10.0.0.0\/16" "PasswordAuthentication yes"

  service_mgnt "ssh" "reload"
}

# Setup roles on the node before enabeling them when attaching to the Core node
#
#   @roles: comma-separated list of roles to setup on the node
#   @core_ip: ip address of the Core node
#   @cluster_hostname: (if router role) setup the hostname
#
#   (if controller role)
#   @cc_shared_dir: path of the shared directory
#   @cc_shared_dir_ip: ip of the machine sharing the CC directory
#   @cc_shared_dir_user: user to connect to the shared directory
#   @cc_shared_dir_password: password to connect to the shared directory
#
function roles_setup() {
  local roles="${1:?missing input}"
  local core_ip="${2:?missing input}"
  local cluster_hostname="${3:?missing input}"

  local cc_shared_dir="${4:?missing input}"
  local cc_shared_dir_ip="${5:?missing input}"
  local cc_shared_dir_user="${6:?missing input}"
  local cc_shared_dir_password="${7:?missing input}"

  local roles_array=($(echo $roles|tr "," " "))

  message "info" "> Setting up Stackato roles"

  # message "info" "> Remove all roles"
  # kato_node_remove "--all-but base primary"

  if [[ "${roles_array[@]/core}" != "${roles_array[@]}" ]]; then
    message "info" "* Setup the core node"
    kato_node_rename $cluster_hostname
    kato_node_setup_core $cluster_hostname
  fi

  if [[ "${roles_array[@]/controller}" != "${roles_array[@]}" ]]; then
    message "info" "* Setup of the controller"
    controller_configure "$cc_shared_dir" "$cc_shared_dir_ip" \
        "$cc_shared_dir_user" "$cc_shared_dir_password"
  fi

  if [[ "${roles_array[@]/router}" != "${roles_array[@]}" ]]; then
    message "info" "* Rename the router with $cluster_hostname"
    kato_node_rename "$cluster_hostname"
  fi
}

# Attach a Stackato node to the Core node
#
#   @core_ip: ip address of the Core node
#   @roles: comma-separated list of roles to enable in the node
#   @mbus_ip: ip of the mbus server
#   @mbus_port: port of the mbus server
#
function node_attach() {
  local core_ip="${1:?missing input}"
  local roles="${2:?missing input}"
  local mbus_ip="${3:?missing input}"
  local mbus_port="${4:?missing input}"

  kato_node_attach "$core_ip" "$roles"
}

# Setup a Stackato node before attaching it to the the Core node
#   @core_ip: ip address of the Core node
#   @core_user: username of the Core node
#   @roles: comma-separated list of roles to enable in the node
function roles_pre_attach_setup() {
  local core_ip="${1:?missing input}"
  local core_user="${2:?missing input}"
  local roles="${3:?missing input}"

  local roles_array=($(echo $roles|tr "," " "))

  if [[ "${roles_array[@]/router}" != "${roles_array[@]}" ]]; then
    # Copy the private SSL key from the core into the router
    ssl_copy_remote_private_key "$core_user" "$core_ip" "stackato.key"
  fi
}

# Setup a Stackato node after it was attached to the Core node
#
#   @roles: comma-separated list of roles enabled in the node
#   @use_proxy: configure the node to use an http/https proxy (true or false)
#   @http_proxy: address of the http proxy
#   @http_proxy_port: port of the http proxy
#
function roles_post_attach_setup() {
  local roles="${1:?missing input}"
  local use_proxy="${2:?missing input}"
  local http_proxy="${3:?missing input}"
  local https_proxy="${4:?missing input}"

  eval "local -A router_properties=""${5#*=}"
  local router_acl_rules="${6:?missing input}"
  local router_acl_drop_conn="${7:?missing input}"

  local roles_array=($(echo $roles|tr "," " "))

  message "info" "> Postattachment setup"

  if [ "$use_proxy" == "true" ]; then
    message "info" "* Setup Apps HTTP/HTTPS Proxy"
    kato_config_set "dea_ng environment/app_http_proxy"  "${http_proxy}"
    kato_config_set "dea_ng environment/app_https_proxy" "${https_proxy}"
    kato_set_upstream_proxy "$http_proxy"
  fi

  # Configure router
  if [[ "${roles_array[@]/router}" != "${roles_array[@]}" ||
        "${roles_array[@]/core}"   != "${roles_array[@]}" ]]; then
    message "info" "* Setup the router"
    router_properties "$(declare -p router_properties)"
    router_configure_acl "$router_acl_rules"
    router_configure_acl_drop_conn "$router_acl_drop_conn"
    kato_role_restart router
  fi
}
