export KATO_BIN=${KATO_BIN:-/home/stackato/bin/kato}

function kato_role() {
  local role="${1:?missing input}"
  local state="${2:?missing input}"

  run_as "stackato" "$KATO_BIN $state $role"
}

function kato_node_attach() {
  local core_ip="${1:?missing input}"
  local roles="${2}"

  local kato_opts=""
  if [ ! -z "${roles}" ]; then
    kato_opts="-e ${roles}"
  fi

  run_as "stackato" "$KATO_BIN node attach ${kato_opts} $core_ip"
}

function kato_node_rename {
  local cluster_hostname="${1:?undefined input}"
  run_as "stackato" "$KATO_BIN node rename $cluster_hostname --no-restart"
}

function kato_node_setup_core {
  local cluster_hostname="${1:?undefined input}"
  run_as "stackato" "$KATO_BIN node setup core api.${cluster_hostname}"
}

function kato_node_setup_load_balancer {
  run_as "stackato" "$KATO_BIN node setup load_balancer --force"
}

function kato_node_remove() {
  local roles="${1:---all}"
  run_as "stackato" "$KATO_BIN role remove ${roles}"
}

function kato_role_add() {
  local roles="${@:?missing input}" # Space-separated list of roles

  for role in "${roles[@]}"; do
    run_as "stackato" "$KATO_BIN role add --no-start ${role}"
  done
}

function kato_role_restart() {
  local roles="${@:?missing input}" # Space-separated list of roles

  run_as "stackato" "$KATO_BIN restart ${roles//,/ }"
}

function kato_set_upstream_proxy() {
  local http_proxy="${1:?undefined input}"

  run_as "stackato" "$KATO_BIN op upstream_proxy set ${http_proxy}"
  service_mgnt "polipo" "restart"
}

function kato_config_get() {
  local key="${@:?missing input}"

  run_as "stackato" "$KATO_BIN config get $key"
}

# Should run this function after the node is attached
# because the redis node data are overwritten by the
# cluster redis data when attaching the node
function kato_config_set() {
  local key="${1:?missing input}"
  local value="${2:?missing input}"

  if [ "$(kato_config_get $key)" != "$value" ]; then
    run_as "stackato" "$KATO_BIN config set $key $value"
  fi
}

function kato_get_core_ip() {
   run_as "stackato" "$KATO_BIN node list | grep primary | cut -d \" \" -f 1"
}
