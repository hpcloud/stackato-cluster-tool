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

function sshfs_add_fstab() {
  local fstab_line="${1:?missing input}"

  if ! grep -q "$fstab_line" /etc/fstab; then
    echo "$fstab_line" >> /etc/fstab
  fi
}

function sshfs_mount() {
  local ip="${1:?missing input}"
  local user="${2:?missing input}"
  local source_path="${3:?missing input}"
  local target_path="${4:?missing input}"

  local source="$user@$ip:$source_path"

  ## Allow non-root users to specify mount options
  sudo sed -i "s/#user_allow_other/user_allow_other/" /etc/fuse.conf
  addgroup $user fuse

  ## Mount the shared filesystem on the mount point
  sshfs_opts_string=""
  fstab_opts_string=""
  if [ ! -z "$SSHFS_OPTS" ]; then
    for sshfs_opt in ${SSHFS_OPTS[@]}; do
      sshfs_opts_string="$sshfs_opts_string -o $sshfs_opt"
      fstab_opts_string="$fstab_opts_string,$sshfs_opt"
    done
    fstab_opts_string="${fstab_opts_string#,}"
  fi

  local fstab="$source $target_path fuse.sshfs,$fstab_opts_string  defaults,_netdev  0  0"

  run_as "$user" "sshfs $sshfs_opts_string $source $target_path"
  sshfs_add_fstab "$fstab"
}
