function sudo_set_passwordless() {
  local user="${1:?missing input}"
  local rule="${2:?missing input}"

  local sudoers_line="$user $rule"
  local sudoers_file="/etc/sudoers"

  if ! grep --quiet "$sudoers_line" $sudoers_file; then
    message "info" "> Set sudo rule for the user $user: $rule"
    echo "$sudoers_line" >> $sudoers_file
  fi
}

