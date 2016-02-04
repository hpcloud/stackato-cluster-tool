function set_apt_proxy() {
  local proxy_ip="${1:?missing input}"
  local proxy_port="${2:?missing input}"

  local apt_proxy_conf="/etc/apt/apt.conf.d/01proxy"

  echo "Acquire::HTTP::Proxy \"http://${proxy_ip}:${proxy_port}\";" > $apt_proxy_conf
  echo "Acquire::HTTPS::Proxy \"false\";" >> $apt_proxy_conf
}

set_bashrc_http_proxy () {
  local user="${1:?missing input}"
  local proxy_ip="${2:?missing input}"
  local proxy_port="${3:?missing input}"

  local bashrc="/home/$user/.bashrc"

  echo "export http_proxy=http://${proxy_ip}:${proxy_port}" >> $bashrc
  echo "export https_proxy=http://${proxy_ip}:${proxy_port}" >> $bashrc
}
