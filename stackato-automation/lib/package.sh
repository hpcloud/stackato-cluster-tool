

function package_manager_update() {
  package_manager "update"
}

function package_manager_install() {
  local package_name="${1:?missing input}"
  package_manager "install" "$package_name"
}

# Generic package manager
# Inputs:
#   @action: update or install
#   @options: if install, the package name
function package_manager() {
  local action="${1:?missing input}"
  local options="${@:2}"

  # APT
  if command -v apt >/dev/null; then
    case "$action" in
      "update" ) apt update;;
      "install") apt install -y $options;;
    esac

  # APT_GET
  elif command -v apt-get >/dev/null; then
    case "$action" in
      "update" ) apt-get update;;
      "install") apt-get install -y $options;;
    esac

  # YUM
  elif command -v yum >/dev/null; then
    case "$action" in
      "update" ) yum update;;
      "install") yum -y install $options;;
    esac

  # Unsupported package manager
  else
    message "error" "Package manager unsupported"
  fi
}
