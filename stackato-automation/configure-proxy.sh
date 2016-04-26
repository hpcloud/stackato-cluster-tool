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
#
function main() {
    local proxy_etc_source="${1:?missing input}"
    local proxy_port="${2:?missing input}"
    local allowed_clients="${3:?missing input}"

    # Install apt cacher
    sudo apt-get update
    sudo apt-get install -y apt-cacher-ng

    # Install the HTTP/HTTPS proxy
    install_polipo
    setup_polipo "$proxy_etc_source" "$proxy_port" "$allowed_clients"
    service_mgnt "polipo" "restart" 
}

main "$@"
