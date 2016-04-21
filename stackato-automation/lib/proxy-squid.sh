# 2014-12-08 Namik.r *All Rights Reserved.
# This script is distributed under a ActiveState licence.
# http://www.activestate.com

# Install and setup SQUID3
# /!\ Not tested and has missing parts
#
#   @ip:
#   @user:
#   @password:
#   @port:
#
#TODO:
# - add a step to check if the package is already installed
# - create a function run_as instead of using become_root
# - create a function install_pkg instead of using apt-get directly
function setup_squid() {
  local ip="${1:?missing input}"
  local user="${2:?missing input}"
  local password="${3:?missing input}"
  local port="${4:?missing input}"

  local become_root=""

  if [ "$(id --user)" != "0" ]; then
    become_root="sudo"
  fi

  $become_root apt-get update
  $become_root apt-get -y install apache2-utils squid3

  $become_root rm /etc/squid3/squid.conf

  $become_root htpasswd -b -c /etc/squid3/squid_passwd $user $password

  $become_root service squid3 restart
}
