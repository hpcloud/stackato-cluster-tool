#!/usr/bin/env bash
# Must setup an HTTP/HTTP proxy and an APT Cacher

set -o errexit  # Exit if a command fails
set -o pipefail # Exit if one command in a pipeline fails
set -o nounset  # Treat  unset  variables and parameters as errors

# Get and move to the current working directory
CWD="$(dirname $0)" && cd $CWD
source load-libs.sh

# Setup a Stackato node
#
#   @proxy_etc_source: location of the proxy etc file templates
#   @proxy_port: proxy server port
#   @allowed_clients: comma-separated list of allowed ip/network
#   @upstream_apt_proxy: APT Proxy to connect to reach package repositories (default: none)
#   @upstream_http_proxy: HTTP/HTTPS Proxy to connect to reach internet (default: none)
#
function main() {
    local proxy_etc_source="${1:?missing input}"
    local proxy_port="${2:?missing input}"
    local allowed_clients="${3:?missing input}"
    local upstream_apt_proxy="${4:-none}"
    local upstream_http_proxy="${4:-none}"

    package_manager_update

    # Install apt cacher
    package_manager_install "apt-cacher-ng"
    service_mgnt "apt-cacher-ng" "restart"

    # Install the HTTP/HTTPS proxy
    package_manager_install "polipo"
    setup_polipo "$proxy_etc_source" "$proxy_port" "$allowed_clients" "$upstream_http_proxy"
    service_mgnt "polipo" "restart"

    # Configure the upstream proxy
    if [ "$upstream_apt_proxy" != "none" -a "$upstream_http_proxy" != "none" ]; then
      local upstream_http_proxy_ip="${upstream_http_proxy%:*}"
      local upstream_http_proxy_port="${upstream_http_proxy##*:}"
      local upstream_apt_proxy_ip="${upstream_apt_proxy%:*}"
      local upstream_apt_proxy_port="${upstream_apt_proxy##*:}"

      # Configure APT
      set_apt_proxy "$upstream_apt_proxy_ip" "$upstream_apt_proxy_port" "$upstream_apt_proxy_port"
      # Set the environment variables
      get_http_proxy_envvars "$upstream_http_proxy_ip" "$upstream_http_proxy_port" "$upstream_http_proxy_port" >> /etc/environment
    fi
}

main "$@"
