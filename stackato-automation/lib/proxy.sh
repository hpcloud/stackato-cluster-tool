function set_apt_proxy() {
  local http_proxy="${1:?missing input}"
  local https_proxy="${2:?missing input}"

  local apt_proxy_conf="/etc/apt/apt.conf.d/01proxy"

  echo "Acquire::HTTP::Proxy \"${http_proxy}\";" > $apt_proxy_conf
  echo "Acquire::HTTPS::Proxy \"${https_proxy}\";" >> $apt_proxy_conf
}

function get_http_proxy_envvars () {
  local http_proxy="${1:?missing input}"
  local https_proxy="${2:?missing input}"

  echo "export http_proxy=${http_proxy}"
  echo "export https_proxy=${https_proxy}"
}
