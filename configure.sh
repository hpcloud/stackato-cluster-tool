#!/usr/bin/env bash
set -e

# Usage message
function usage() {
  >&2 echo "
    Configure Terraform to build a Stackato cluster

    Support OpenStack only (later Amazon)

    usage: $0 PARAMETERS

    PARAMETERS:
      -c | --config: Terraform configuration path (default: $TF_CONFIG_PATH)
      -p | --platform: Cluster platform (openstack or amazon - default: $PLATFORM)
      -n | --name: Cluster name (e.g. yourname)
      -h | --hostname: Hostname of the cluster (e.g. yourname.com)
      -k | --ssh-key: SSH key to connect to the core node

      -d  | --dea: number of DEA nodes (default: $NB_DEA)
      -cc | --controller: number of additional Cloud Controller nodes (default: $NB_CONTROLLER)
      -ds | --dataservice: number of Data Service nodes (default: $NB_DATASERVICES)
      
    OTHER PARAMETERS:
      --debug: Turn on the debug mode
      -h | --help: Print the usage
  "
}

export MSG_DONE_OPENSTACK="Done.\nNext step:\n1. Export OS_AUTH_URL, OS_TENANT_NAME, OS_USERNAME and OS_PASSWORD"
export MSG_DONE="
2. Move to the Terreform folder: %s
3. Start the cluster with the Terraform (terraform apply)
4. Destroy the cluster with Terraform (terraform destroy)\n"

function main() {

  # Default value
  export PLATFORM="openstack"
  export TF_CONFIG_PATH="out"
  export NB_DATASERVICES="1"
  export NB_DEA="2"
  export NB_CONTROLLER="1"

  CWD="$(dirname $0)" && cd $CWD

  # Parse parameters
  [ "$#" -eq 0 ] && usage && exit 1
  while true; do
    case "$1" in
      -c  | --config      ) export TF_CONFIG_PATH="$2"    ; shift 2 ;;
      -p  | --platform    ) export PLATFORM="$2"          ; shift 2 ;;
      -n  | --name        ) export CLUSTER_NAME="$2"      ; shift 2 ;;
      -h  | --hostname    ) export CLUSTER_HOSTNAME="$2"  ; shift 2 ;;
      -d  | --dea         ) export NB_DEA="$2"            ; shift 2 ;;
      -cc | --controller  ) export NB_CONTROLLER="$2"     ; shift 2 ;;
      -ds | --dataservice ) export NB_DATASERVICES="$2"   ; shift 2 ;;
      -k  | --ssh-key     ) export SSH_KEY_NAME="$2"      ; shift 2 ;;
      --debug             ) set -x                        ; shift 1 ;;
      -h | --help         ) usage ; exit 1 ;;
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
    set_openstack_config $TF_CONFIG_PATH/config-openstack.tf $SSH_KEY_NAME

    >&2 printf "$MSG_DONE_OPENSTACK"
  fi

  >&2 printf "$MSG_DONE" "$TF_CONFIG_PATH"
}


function set_openstack_config() {
  local openstack_config_path="${1:? missing input}"
  local ssh_key_name="${2:? missing input}"

  sed -i "/variable ssh_key_name/{N;N;s/default = .*/default = \"$ssh_key_name\"/}" $openstack_config_path
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

  # Set the cluster name
  sed -i "/variable cluster_name/{N;N;s/default = .*/default = \"$cluster_name\"/}" $config_path

  # Set the cluster hostname
  sed -i "/variable cluster_hostname/{N;N;s/default = .*/default = \"$cluster_hostname\"/}" $config_path

  # Set the number of DEA
  sed -i "/variable dea/{N;N;N;s/count\" = .*/count\" = $nb_dea/}" $config_path

  # Set the number of dataservices
  sed -i "/variable dataservices/{N;N;N;s/count\" = .*/count\" = $nb_dataservices/}" $config_path

  # Set the number of controller
  sed -i "/variable controller/{N;N;N;s/count\" = .*/count\" = $nb_controller/}" $config_path
}

main "$@"
