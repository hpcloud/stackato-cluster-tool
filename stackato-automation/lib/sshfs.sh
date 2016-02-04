function sshfs_wait_source() {
  local ip="${1:?missing input}"
  local user="${2:?missing input}"
  local source_path="${3:?missing input}"
  local sleep_time="${4:?missing input}"

  while ! run_as "$user" "ssh -q $user@$ip test -d $source_path"; do
    message "info" "Waiting for $user@$ip:$source_path to exist"
    sleep 5
  done
}

function sshfs_mount() {
  local ip="${1:?missing input}"
  local user="${2:?missing input}"
  local source_path="${3:?missing input}"
  local target_path="${4:?missing input}"

  ## Allow non-root users to specify mount options
  sudo sed -i "s/#user_allow_other/user_allow_other/" /etc/fuse.conf
  addgroup $user fuse
  ## Mount the shared filesystem on the mount point
  sshfs_opts_string=""
  if [ ! -z "$SSHFS_OPTS" ]; then
    for sshfs_opt in ${SSHFS_OPTS[@]}; do
      sshfs_opts_string="$sshfs_opts_string -o $sshfs_opt"
    done
  fi
  run_as "$user" "sshfs $sshfs_opts_string $user@$ip:$source_path $target_path"
}
