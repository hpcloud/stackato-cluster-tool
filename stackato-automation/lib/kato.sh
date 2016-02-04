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

function kato_defer_node_setup_core {
  local cluster_hostname="${1:?undefined input}"
  run_as "stackato" "$KATO_BIN node setup core api.${cluster_hostname}"
}

function kato_node_remove() {
  local roles="${1:---all}"
  run_as "stackato" "$KATO_BIN node remove ${roles}"
}

function kato_role_add() {
  local roles="${@:?missing input}" # Space-separated list of roles

  for role in "${roles[@]}"; do
    run_as "stackato" "$KATO_BIN role add --no-start ${role}"
  done
}

function kato_set_upstream_proxy() {
  local proxy_ip="${1:?undefined input}"
  local proxy_port="${2:?undefined input}"

  run_as "stackato" "$KATO_BIN op upstream_proxy set ${proxy_ip}:${proxy_port}"
  run_as "stackato" "$KATO_BIN config set dea_ng environment/app_http_proxy http://${proxy_ip}:${proxy_port}"
  run_as "stackato" "$KATO_BIN config set dea_ng environment/app_https_proxy http://${proxy_ip}:${proxy_port}"
  service_mgnt "polipo" "restart"
}
