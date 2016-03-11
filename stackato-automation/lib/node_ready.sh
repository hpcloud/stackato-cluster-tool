export FLAG_DIR=${FLAG_DIR:-"/home/stackato"}

function node_ready.set_flag() {
  local flag_name="${1:?missing input}"

  kato_op_defer_commands "touch ${FLAG_DIR}/$flag_name"
}

function node_ready.wait_flag() {
  local flag_name="${1:?missing input}"
  local sleep_time="${2:-5}"

  local flag_path="${FLAG_DIR}/$flag_name"

  while [ ! -f "$flag_path" -a "$(status stackato)" != "stackato start/running" ]; do
    >&2 echo "Waiting for node to be ready (flag $flag_path)"
    sleep $sleep_time
  done

}

function node_ready.delete_flag() {
  local flag_name="${1:?missing input}"

  rm $FLAG_DIR/$flag_name
}
