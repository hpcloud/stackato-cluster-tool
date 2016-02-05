function ssh_set_PasswordAuthentication {
  local enabled="${1:?missing input}"

  local sshd_config="/etc/ssh/sshd_config"
  local sshd_property="PasswordAuthentication"

  if [ $enabled == "yes" -o $enabled == "no" ]; then
    sed -i "s/$sshd_property.*/$sshd_property $enabled/" $sshd_config
  else
    >&2 echo "ssh_set_passwordauthentication - unknown state $enabled"
  fi
}

function ssh_set_StrictHostKeyChecking {
  local ssh_config="${1:?missing input}"
  local host_filter="${2:?missing input}"
  local enabled="${3:?missing input}"

  local sshd_property="StrictHostKeyChecking"

  if [ $enabled == "yes" -o $enabled == "no" ]; then
    echo -e "Host $host_filter\n\t$sshd_property $enabled" > $ssh_config
  else
    >&2 echo "ssh_set_passwordauthentication - unknown state $enabled"
  fi
}

function ssh_get_remote_public_key() {
  local ip="${1:?missing input}"
  local user="${2:?missing input}"
  local password="${3:?missing input}"

  local public_key="/home/$user/.ssh/id_rsa.pub"

  sshpass -p "${password}" ssh -o StrictHostKeyChecking=no ${user}@${ip} cat $public_key
}

function ssh_copy_ssh_key() {
  local ip="${1:?missing input}"
  local user="${2:?missing input}"
  local password="${3:?missing input}"

  run_as "stackato" "sshpass -p \"${password}\" ssh-copy-id ${user}@${ip}"
}
