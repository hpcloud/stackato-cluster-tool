function vbox_runcmd() {
  local cmd="${1:-vboxmanage}"
  local cmd_opts="${2}"

  $cmd $cmd_opts
}

