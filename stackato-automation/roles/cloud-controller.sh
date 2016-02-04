function controller_configure() {
  # Server storing the shared Cloud Controller data
  local controller_shared_dir_ip=${1:?missing input}
  local controller_shared_dir_password="${2:-missing input}"
  local controller_shared_dir="${CONTROLLER_SHARED_DIR:=/mnt/controller/}"

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

  kato_role_add "controller"
  controller_make_new_environment ${controller_mount_dir} ${stackato_user} ${stackato_group}

  # Connect to the controller shared directory
  if ! ip -4 address | grep -q ${controller_shared_dir_ip}; then
    ssh_copy_ssh_key ${controller_shared_dir_ip} ${stackato_user} ${controller_shared_dir_password}
    sshfs_wait_source ${controller_shared_dir_ip} ${stackato_user} ${controller_shared_dir} 5
    sshfs_mount ${controller_shared_dir_ip} ${stackato_user} ${controller_shared_dir} ${controller_mount_dir}
  fi

  controller_move_data ${data_dir} ${stackato_user} ${controller_mount_dir}
  kato_role "controller" "start"
}

function controller_make_new_environment() {
  local controller_mount_dir="${1:?missing input}"
  local dir_user="${2:?missing input}"
  local dir_group="${3:?missing input}"

  # Perform the following actions on the core node and each additional controller node
  ## Create a mount point
  sudo mkdir -p $controller_mount_dir
  ## Give stackato ownership of the mount point
  sudo chown -R $dir_user:$dir_group $controller_mount_dir
}

function controller_move_data() {
  local data_dir="${1:?missing input}"
  local data_cc_droplets_dir="${2:?missing input}"
  local controller_mount_dir="${3:?missing input}"

  ## Move aside the original data directory
  [ -d "$data_dir" ] && sudo mv $data_dir $data_dir.old
  ## Create a symlink from the data directory to the mount point
  [ ! -L "$data_dir" ] && sudo ln -s $controller_mount_dir $data_dir
  ## Move the original staged_droplet_uploads directory
  [ -d "$data_cc_droplets_dir" ] && sudo mv $data_cc_droplets_dir $data_cc_droplets_dir.old
  ## Create a symlink from staged_droplet_uploads directory to the mount point
  [ ! -L "$data_cc_droplets_dir" ] && sudo ln -s $controller_mount_dir $data_cc_droplets_dir

  # Copy the controller data and the droplets on the core node into the shared directory
  sudo rsync -a $data_dir.old/ $data_dir
  sudo rsync -a $data_cc_droplets_dir.old/ $data_cc_droplets_dir
}
