#!/usr/bin/env bash
set -e # Exit on error

# Constants
CWD="$(cd $(dirname $0) && pwd)"        # Script directory
PLATFORM_SUPPORT=(openstack amazon-aws vsphere) # Supported platforms by this tool

# Default configuration
PLATFORM_DEFAULT="openstack"
VERSION_DEFAULT="terraform/stackato-version/var-stackato-362.tf"
OUTPUT_DIR_DEFAULT="$CWD/out"

## Message
MSG_UNSUPPORTED_PLATFORM="The platform %s is not supported\n"
MSG_SEE_USAGE="See usage ($0 --help)\n"
MSG_PLATFORM_DIR_NOT_FOUND="The plaform directory %s not found\n"
MSG_INTERNAL_UNKNOWN_MSG_TYPE="Internal error: unknown message type %s\n"
MSG_TERRAFORM_CONFIG_COPY_DONE="Terraform config copied for %s for %s:\n"

# Print the usage
function usage() {
  >&2 echo "
  usage: $0 [OPTIONS] [-p | --platform PLATFORM] [-v | --version VERSION]

  Create a folder with the Terraform files to deploy a cluster
  on the plaform PLATFORM.

  PLATFORM = ${PLATFORM_SUPPORT[@]} (default: $PLATFORM_DEFAULT)
  VERSION = Stackato version file path (default: $VERSION_DEFAULT)

  OPTIONS:
    -o | --out: Output directory (default: $OUTPUT_DIR_DEFAULT)
    -p | --platform: Platform to deploy (default: $PLATFORM_DEFAULT)
    -v | --version: Path of the Stackato version file (default: $VERSION_DEFAULT)
    -lb| --load-balancer: Add the load balancer configuration
    -h | --help: Show help message
    -d | --debug: Turn on the debug mode

  Note:
  For scripting, $0 writes in stdout the path of the output directory.
  "
}

# Print messages to the user
function message() {
  local msg_type="$1"
  local msg="$2"
  local vars="${@:3}"

  case "$msg_type" in
    "error")  >&2 printf "$msg" $vars; exit 1;;
    "info")   >&2 printf "$msg" $vars;;
    "stdout") >&1 printf "$msg" $vars;;
    *)        >&2 printf "$MSG_INTERNAL_UNKNOWN_MSG_TYPE" "$msg_type"; exit 1;;
  esac
}

# Check that the platform requested by the user is supported by the tool
function check_platform_support() {
  local platform="$1" # Platform to check

  if [[ "${PLATFORM_SUPPORT[@]#$platform}" == "${PLATFORM_SUPPORT[@]}" ]]; then
    message "error" "$MSG_UNSUPPORTED_PLATFORM"
  fi
}

# Copy the Terraform configuration to an output directory for a target platform
function copy_terraform_config() {
  local platform="$1"
  local version="$2"
  local output_dir="$3"

  local platform_dir="$CWD/terraform/$platform"
  local version_dir="$version"
  local common_tf_dir="$CWD/terraform/common"
  local provisioner_dir="$CWD/stackato-automation"
  local cloudinit_dir="$CWD/cloudinit/*"

  if [ ! -d "$platform_dir" ]; then
    message "error" "$MSG_PLATFORM_DIR_NOT_FOUND" "$platform_dir"
  else
    rm -rf $output_dir
    mkdir -p $output_dir
    # Copy the platform specific Terraform files
    find $platform_dir/* -maxdepth 0 -type f \( -name "*.tf" -or -name "*.tpl" \) -exec cp {} $output_dir \;
    # Copy the Terraform file targetting a specific version of Stackato
    cp $version_dir $output_dir/var-stackato-version.tf
    cp $(dirname $version_dir)/var-ubuntu-images.tf $output_dir/var-ubuntu-images.tf

    cp $common_tf_dir/* $output_dir       # Copy the common Terraform files
    cp -r $provisioner_dir $output_dir    # Copy the provisioner scripts
    cp -r $cloudinit_dir $output_dir      # Copy the Cloudinit configuration
    message "info" "$MSG_TERRAFORM_CONFIG_COPY_DONE" "$version" "$platform"
    message "stdout" "$output_dir\n"
  fi
}

function copy_terraform_loadbalancer() {
  local platform="$1"
  local output_dir="$2"
  local ssl_cert="$CWD/certs"

  cp $CWD/terraform/$platform/load-balancer/*.tf $output_dir
  cp -r $ssl_cert/* $output_dir
}

# Main function
function main() {
  local platform="$PLATFORM_DEFAULT"     # Platform hosting the cluster
  local version="$VERSION_DEFAULT"       # Version to deploy
  local output_dir="$OUTPUT_DIR_DEFAULT" # Default output dir
  local add_load_balancer=""

  # Parse parameters
  while true; do
    case "$1" in
      -d | --debug )    set -x; shift ;;
      -h | --help  )    usage ; exit 1 ;;
      -p | --platform ) shift; platform="$1";   shift;;
      -v | --version )  shift; version="$1";    shift;;
      -lb| --load-balancer ) add_load_balancer="1"; shift ;;
      -o | --out )      shift; output_dir="$1"; shift;;
      -- ) shift; break ;;
      "" ) break ;;
      * ) echo "Invalid parameter '$1'"; usage ; exit 1 ;;
    esac
  done

  check_platform_support "$platform"
  copy_terraform_config "$platform" "$version" "$output_dir"
  [ ! -z "$add_load_balancer" ] && copy_terraform_loadbalancer "$platform" "$output_dir"

}

main "$@"
