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
  local pubkey_path=${4:?missing input}

  cat $pubkey_path | sshpass -p "${password}" ssh -o StrictHostKeyChecking=no ${user}@${ip} 'cat >> .ssh/authorized_keys'
}

function ssh_add_match() {
  local ssh_config="${1:?missing input}"
  local match_filter="${2:?missing input}"

  if ! grep --quiet "Match $match_filter" $ssh_config; then
    sed -i -e "\$aMatch $match_filter" $ssh_config
  fi
}

function ssh_add_match_option() {
  local ssh_config="${1:?missing input}"
  local match_filter="${2:?missing input}"
  local option="${3:?missing input}"

  sed -i "s/^Match ${match_filter}.*/&\n\t${option}/" $ssh_config
}
