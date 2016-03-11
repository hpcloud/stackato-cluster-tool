function fstab_delete_line() {
  local pattern="${1:?missing input}"
  sed -i /$pattern/d /etc/fstab
}

function umount_fs() {
  local fs="${1:?missing input}"
  
}
