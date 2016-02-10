function kato_op_defer {
  local cmd="${1:?undefined input}"
  run_as "stackato" "/home/stackato/bin/kato op defer \"$cmd\" --run-as-root --post-start"
}

function kato_defer_attach_node() {
  local core_ip="${1:?undefined input}"
  local core_user="${2:?undefined input}"
  local core_password="${3:?undefined input}"

  local core_ssh_pub_key="/home/$core_user/.ssh/id_rsa.pub"
  local kato_bin="/home/$core_user/bin/kato"

  kato_op_defer "version; sshpass -p ${core_password} ssh-copy-id -i $core_ssh_pub_key ${core_user}@${core_ip}; $kato_bin node attach ${core_ip}"
}

function kato_op_defer_script() {
  local script="${1:?undefined input}"
  local script_opts="${@:2}"

  chmod u+x ${script}

  if [ -z "${script_opts}" ]; then
    kato_op_defer "version; ${script}"
  else
    kato_op_defer "version; ${script} ${script_opts[@]}"
  fi
}

function kato_op_defer_commands() {
  local commands="${1:?missing input}"

  kato_op_defer "version; ${commands}"
}
