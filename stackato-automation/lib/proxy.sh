function set_apt_proxy() {
  local proxy_ip="${1:?missing input}"
  local proxy_http_port="${2:?missing input}"
  local proxy_https_port="${3:?missing input}"

  local apt_proxy_conf="/etc/apt/apt.conf.d/01proxy"

  echo "Acquire::HTTP::Proxy \"http://${proxy_ip}:${proxy_http_port}\";" > $apt_proxy_conf
  echo "Acquire::HTTPS::Proxy \"http://${proxy_ip}:${proxy_https_port}\";" >> $apt_proxy_conf
}

function get_http_proxy_envvars () {
  local proxy_ip="${1:?missing input}"
  local http_proxy_port="${2:?missing input}"
  local https_proxy_port="${3:?missing input}"

  echo "export http_proxy=http://${proxy_ip}:${http_proxy_port}"
  echo "export https_proxy=http://${proxy_ip}:${https_proxy_port}"
}
