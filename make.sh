#!/usr/bin/env bash
set -e # Exit on error

# Constants
CWD="$(readlink -f $(dirname $0))"; cd $CWD
PLATFORM_SUPPORT=(openstack amazon-aws)          # Supported platforms by this tool

# Default configuration
PLATFORM_DEFAULT="openstack"
VERSION_DEFAULT="terraform/stackato-version/var-stackato-361.tf"
OUTPUT_DIR_DEFAULT="$CWD/out"

## Message
MSG_UNSUPPORTED_PLATFORM="The platform %s is not supported\n"
MSG_SEE_USAGE="See usage ($0 --help)\n"
MSG_PLATFORM_DIR_NOT_FOUND="The plaform directory %s not found\n"
MSG_INTERNAL_UNKNOWN_MSG_TYPE="Internal error: unknown message type %s\n"
MSG_TERRAFORM_CONFIG_COPY_DONE="Terraform config copied for %s for %s:\n"

# Print the usage
function usage(){
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
    find $CWD -maxdepth 1 -type f \( -name "*.tf" -or -name "*.tpl" \) -exec cp {} $output_dir \;
    cp $platform_dir/* $output_dir
    cp $version_dir $output_dir/var-stackato-version.tf
    cp $common_tf_dir/* $output_dir
    cp -r $provisioner_dir $output_dir
    cp -r $cloudinit_dir $output_dir
    message "info" "$MSG_TERRAFORM_CONFIG_COPY_DONE" "$version" "$platform"
    message "stdout" "$output_dir\n"
  fi

}

# Main function
function main() {
  local platform="$PLATFORM_DEFAULT"     # Platform hosting the cluster
  local version="$VERSION_DEFAULT"       # Version to deploy
  local output_dir="$OUTPUT_DIR_DEFAULT" # Default output dir

  # Parse parameters
  while true; do
    case "$1" in
      -d | --debug )    set -x; shift ;;
      -h | --help  )    usage ; exit 1 ;;
      -p | --platform ) shift; platform="$1";   shift;;
      -v | --version )  shift; version="$1";    shift;;
      -o | --out )      shift; output_dir="$1"; shift;;
      -- ) shift; break ;;
      "" ) break ;;
      * ) echo "Invalid parameter '$1'"; usage ; exit 1 ;;
    esac
  done

  check_platform_support "$platform"
  copy_terraform_config "$platform" "$version" "$output_dir"
}

main "$@"
