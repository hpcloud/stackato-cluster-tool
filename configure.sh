#!/usr/bin/env bash
set -e

# Default value
export PLATFORM="openstack"
export TF_CONFIG_PATH="out"
export NB_DATASERVICES="1"
export NB_DEA="2"
export NB_CONTROLLER="1"

# Usage message
function usage() {
  >&2 echo "$MSG_USAGE"
}

function usage_long() {
  usage
  >&2 echo "$MSG_USAGE_LONG"
}

export MSG_USAGE_OPENSTACK="  For OpenStack:

      --os-region: Region to deploy the cluster
      --ext-gw-uuid: External gateway uuid
      --floating-ip-pool: Floating IP pool name"

export MSG_USAGE="
    Configure and update Terraform files to build a Stackato cluster

    Support OpenStack only (later Amazon)

    usage: $0 PARAMETERS

    PARAMETERS:
      -f | --file: configuration file containing the parameters (see $0 --help-long)
      -c | --config: Terraform configuration path (default: $TF_CONFIG_PATH)
      -p | --platform: Cluster platform (openstack or amazon - default: $PLATFORM)
      -n | --name: Cluster name (e.g. yourname)
      -h | --hostname: Hostname of the cluster (e.g. yourname.com)
      -k | --ssh-key: SSH key to connect to the core node

      -d  | --dea: number of DEA nodes (default: $NB_DEA)
      -cc | --controller: number of additional Cloud Controller nodes (default: $NB_CONTROLLER)
      -ds | --dataservice: number of Data Service nodes (default: $NB_DATASERVICES)
    
    $MSG_USAGE_OPENSTACK

    OTHER PARAMETERS:
      --debug: Turn on the debug mode
      -h | --help: Print the usage
      --help-long: Print the full usage (tips: $0 --help-long|less)"

export MSG_USAGE_LONG="
    Structure of FILE for the option -f / --file:

      (-c|--config)      export TF_CONFIG_PATH
      (-p|--platform)    export PLATFORM
      (-n|--name)        export CLUSTER_NAME
      (-h|--hostname)    export CLUSTER_HOSTNAME
      (-d|--dea)         export NB_DEA
      (-cc|--controller) export NB_CONTROLLER
      (-ds|--dataserver) export NB_DATASERVICES
      (-k|--ssh-key)     export SSH_KEY_NAME

      OpenStack:
      (--os-region)        export OS_REGION_NAME
      (--ext-gw-uuid)      export EXTERNAL_GATEWAY_UUID
      (--floating-ip-pool) export FLOATING_IP_POOL_NAME
"

export MSG_DONE_OPENSTACK="Done.\nNext step:\n1. Export OS_AUTH_URL, OS_TENANT_NAME, OS_USERNAME and OS_PASSWORD"
export MSG_DONE="
2. Move to the Terreform folder: %s
3. Start the cluster with the Terraform (terraform apply)
4. Destroy the cluster with Terraform (terraform destroy)\n"

# Return the value of the parameter -f / --file
function get_option_file() {
  local option_index=1
  local file_path=""

  for i in $@; do
    if [ "$i" == "--file" -o "$i" == "-f" ]; then
      file_path=${@:$((option_index + 1)):1}
    else
      option_index=$(( $option_index + 1 ))
    fi
  done

  echo "$file_path"
}

function main() {

  CWD="$(dirname $0)" && cd $CWD

  # Get the paramters from the parameter -f / --file
  if [[ "$@" == *"--file"* || "$@" == *"-f"* ]]; then
    source $(get_option_file "$@")
  fi

  # Parse parameters
  [ "$#" -eq 0 ] && usage && exit 1
  while true; do
    case "$1" in
      # Stackato options:
      -c  | --config      ) export TF_CONFIG_PATH="$2"    ; shift 2 ;;
      -p  | --platform    ) export PLATFORM="$2"          ; shift 2 ;;
      -n  | --name        ) export CLUSTER_NAME="$2"      ; shift 2 ;;
      -h  | --hostname    ) export CLUSTER_HOSTNAME="$2"  ; shift 2 ;;
      -d  | --dea         ) export NB_DEA="$2"            ; shift 2 ;;
      -cc | --controller  ) export NB_CONTROLLER="$2"     ; shift 2 ;;
      -ds | --dataservice ) export NB_DATASERVICES="$2"   ; shift 2 ;;
      -k  | --ssh-key     ) export SSH_KEY_NAME="$2"      ; shift 2 ;;

      # OpenStack options:
      --os-region )        export OS_REGION_NAME="$2"        ; shift 2 ;;
      --ext-gw-uuid )      export EXTERNAL_GATEWAY_UUID="$2" ; shift 2 ;;
      --floating-ip-pool ) export FLOATING_IP_POOL_NAME="$2" ; shift 2 ;;

      # Other options:
      --debug             ) set -x                        ; shift 1 ;;
      -h | --help         ) usage ; exit 1 ;;
      --help-long         ) usage_long ; exit 1 ;;
      -- ) shift; break ;;
      "" ) break ;;
      * ) echo "Invalid parameter '$1'"; usage ; exit 1 ;;
    esac
  done

  TF_CONFIG_PATH="$(readlink -f $TF_CONFIG_PATH)"

  # Check all parameters exist
  : ${CLUSTER_NAME:?missing input -n}
  : ${CLUSTER_HOSTNAME:? missing input -h}
  : ${NB_DEA:? missing input -d}
  : ${NB_CONTROLLER:? missing input -c}
  : ${NB_DATASERVICES:? missing input -ds}
  : ${SSH_KEY_NAME:? missing input -k}
  
  set_main_config $TF_CONFIG_PATH/config.tf $CLUSTER_NAME $CLUSTER_HOSTNAME \
    $NB_DEA $NB_CONTROLLER $NB_DATASERVICES

  if [ "$PLATFORM" == "openstack" ]; then
    : ${OS_REGION_NAME:?missing input --os-region}
    : ${EXTERNAL_GATEWAY_UUID:?missing input --external_gateway_uuid}
    : ${FLOATING_IP_POOL_NAME:?missing input --floating_ip_pool_name}

    set_openstack_config $TF_CONFIG_PATH/config-openstack.tf $SSH_KEY_NAME $OS_REGION_NAME \
      $EXTERNAL_GATEWAY_UUID $FLOATING_IP_POOL_NAME

    >&2 printf "$MSG_DONE_OPENSTACK"
  fi
  
  >&2 printf "$MSG_DONE" "$TF_CONFIG_PATH"
}

function set_tf_variable() {
  local file="${1:?missing input}"
  local variable="${2:?missing input}"
  local variable_position="${3:?missing input}"
  local key="${4:?missing input}"
  local value="${5:?missing input}"

  local sed_jumps=$(printf "N;%.0s" $(seq 1 $variable_position)})

  sed -i "/variable $variable/{$sed_jumps s/$key = .*/$key = \"$value\"/}" $file
}

function set_openstack_config() {
  local openstack_config_path="${1:? missing input}"
  local ssh_key_name="${2:? missing input}"
  local os_region_name="${3:?missing input}"
  local external_gateway_uuid="${4:?missing input}"
  local floating_ip_pool_name="${5:?missing input}"
  
  set_tf_variable $openstack_config_path "ssh_key_name" 2 "default" $ssh_key_name
  set_tf_variable $openstack_config_path "os_region_name" 2 "default" $os_region_name
  set_tf_variable $openstack_config_path "external_gateway_uuid" 2 "default" $external_gateway_uuid
  set_tf_variable $openstack_config_path "floating_ip_pool_name" 2 "default" $floating_ip_pool_name
}

function set_amazon_config() {
  :
}

function set_main_config() {
  local config_path="${1:?missing input}"
  local cluster_name="${2:?missing input}"
  local cluster_hostname="${3:?missing input}"
  local nb_dea="${4:?missing input}"
  local nb_controller="${5:?missing input}"
  local nb_dataservices="${6:?missing input}"

  set_tf_variable $config_path "cluster_name" 2 "default" "$cluster_name"   # Set the cluster name
  set_tf_variable $config_path "cluster_hostname" 2 "default" "$cluster_hostname"   # Set the cluster hostname
  set_tf_variable $config_path "dea" 3 "count" "$nb_dea"                    # Set the number of DEA
  set_tf_variable $config_path "dataservices" 3 "count" "$nb_dataservices"  # Set the number of dataservices
  set_tf_variable $config_path "controller" 3 "count" "$nb_controller"      # Set the number of controller
}

main "$@"
