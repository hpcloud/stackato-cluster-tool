# Copy a remote SSL private key
# Precondition:
#   Passwordless SSH with the remote ip
# Inputs:
#   remote_user: username to connect on the remote machine containing the key
#   remote_ip: ip to connect on the remote machine containing the key
#   private_key_name: name of the private key
#   ssl_private_path: (optional) Path of the SSL private keys
function ssl_copy_remote_private_key() {
  local remote_user="${1:?missing input}"
  local remote_ip="${2:?missing input}"
  local private_key_name="${3:?missing input}"
  local ssh_key_path="${4:-/home/$remote_user/.ssh/id_rsa}"
  local ssl_private_path="${5:-/etc/ssl/private}"

  local key_path="${ssl_private_path}/${private_key_name}"

  ssh_get_remote_file "$ssh_key_path" "$remote_user" "$remote_ip" "$key_path" "$key_path"
  chmod 400 $key_path
  chown root:root $key_path
}
