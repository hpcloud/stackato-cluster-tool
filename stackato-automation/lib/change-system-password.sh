function change_system_password() {
  local user="$1"
  local password="$2"
  run_as "root" "echo $user:$password | chpasswd"
}
