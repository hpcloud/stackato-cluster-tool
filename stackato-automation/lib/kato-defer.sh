function kato_op_defer {
  local cmd="${1:?undefined input}"
  run_as "stackato" "/home/stackato/bin/kato op defer \"$cmd\" --run-as-root --post-start"
}

function kato_defer_node_rename {
  local cluster_hostname="${1:?undefined input}"
  kato_op_defer "node rename $cluster_hostname --no-restart"
}

function kato_defer_node_setup_core {
  local cluster_hostname="${1:?undefined input}"
  kato_op_defer "node setup core api.${cluster_hostname}"
}
