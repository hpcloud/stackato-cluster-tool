function ssh_set_PasswordAuthentication {
  local enabled="$1"

  local sshd_config="/etc/ssh/sshd_config"
  local sshd_property="PasswordAuthentication"

  if [ $enabled == "yes" -o $enabled == "no" ]; then
    sed -i "s/$sshd_property.*/$sshd_property $enabled/" $sshd_config
  else
    >&2 echo "ssh_set_passwordauthentication - unknown state $enabled"
  fi
}

function ssh_set_StrictHostKeyChecking {
  local ssh_config="$1"
  local host_filter="$2"
  local enabled="$3"

  local sshd_property="StrictHostKeyChecking"

  if [ $enabled == "yes" -o $enabled == "no" ]; then
    echo -e "Host $host_filter\n\t$sshd_property $enabled" > $ssh_config
  else
    >&2 echo "ssh_set_passwordauthentication - unknown state $enabled"
  fi
}
