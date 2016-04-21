function install_polipo() {
  local package="polipo"

  apt-get install "$package"
}

function setup_polipo() {
    local etc_source_path="${1:?missing input}"
    local proxy_port="${2:?missing input}"
    local allowed_clients="${3:?missing input}"

    local etc_path="/etc/polipo"
    local option_path="$etc_path/options"

    mkdir -p $etc_path
    cp -r $etc_source_path/* $etc_path

    sed -i "s/^proxyPort.*/proxyPort = $proxy_port/"  $option_path
    sed -i -e "\$aallowedClients $allowed_clients/" $option_path
}
