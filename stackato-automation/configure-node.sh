#!/usr/bin/env bash
# Setup a Stackato node
# Required parameters:
# --core-ip (e.g. 10.0.0.2)
# --cluster-hostname (e.g. myclusrer.com)
# --roles (e.g. dea,controller)

set -o errexit  # Exit if a command fails
set -o pipefail # Exit if one command in a pipeline fails
set -o nounset  # Treat  unset  variables and parameters as errors

# Get and move to the current working directory
CWD="$(dirname $0)" && cd $CWD
source load-libs.sh

# Setup a Stackato node
function main() {
    setup_node "$@"
}

main "$@"
