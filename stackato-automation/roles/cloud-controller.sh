function controller_configure() {
  # Server storing the shared Cloud Controller data
  local controller_shared_dir="${1:?missing input}"
  local controller_shared_dir_ip="${2:?missing input}"
  local controller_shared_dir_user="${3:?missing input}"
  local controller_shared_dir_password="${4:-missing input}"

  # Default location of the Cloud Controller data
  local data_dir="${DATA_DIR:=/home/stackato/stackato/data}"
  local data_cc_droplets_dir="${DATA_CC_DROPLETS_DIR:=/var/stackato/data/cloud_controller_ng/tmp/staged_droplet_uploads}"

  # New location of the Cloud controller data (could be a bigger disk)
  local controller_mount_dir="${CONTROLLER_MOUNT_DIR:=/mnt/controller}"

  # SSHFS mount options
  local SSHFS_OPTS=( idmap=user
                     reconnect
                     allow_other
                     ServerAliveInterval=15 )

  local stackato_user="${STACKATO_USER:=stackato}"
  local stackato_group="${STACKATO_GROUP:=stackato}"
  local fuse_conf_path="${FUSE_CONF_PATH:=/etc/fuse.conf}"
  local ssh_pubkey_path="${SSH_PUBKEY_PATH:-/home/stackato/.ssh/id_rsa.pub}"

  controller_make_new_environment ${controller_mount_dir} ${stackato_user} ${stackato_group}

  # Connect to the controller shared directory
  if ! ip -4 address | grep -q ${controller_shared_dir_ip}; then
    message "info" "Configure SSHFS with ${stackato_user}@${controller_shared_dir_ip}:${controller_shared_dir}"
    ssh_copy_ssh_key ${controller_shared_dir_ip} ${stackato_user} ${controller_shared_dir_password} ${ssh_pubkey_path}
    sshfs_wait_source ${controller_shared_dir_ip} ${stackato_user} ${controller_shared_dir} 5
    sshfs_mount ${controller_shared_dir_ip} ${stackato_user} ${controller_shared_dir} ${controller_mount_dir}
  fi

  controller_move_data ${data_dir} ${data_cc_droplets_dir} ${controller_mount_dir}
}

function controller_make_new_environment() {
  local controller_mount_dir="${1:?missing input}"
  local dir_user="${2:?missing input}"
  local dir_group="${3:?missing input}"

  # Perform the following actions on the core node and each additional controller node
  ## Create a mount point
  mkdir -p $controller_mount_dir
  ## Give stackato ownership of the mount point
  chown -R $dir_user:$dir_group $controller_mount_dir
}

function controller_move_data() {
  local data_dir="${1:?missing input}"
  local data_cc_droplets_dir="${2:?missing input}"
  local controller_mount_dir="${3:?missing input}"

  for dir in $data_dir $data_cc_droplets_dir; do
    if [ -d "$dir" ]; then
          # Move aside the original directory
          mv $dir $dir.old
          # Create a symlink from the directory to the mount point
          ln -s $controller_mount_dir $dir
          # Copy the controller data into the shared directory
          rsync -a $dir.old/ $dir
          rm -r $dir.old
    fi
  done
}
