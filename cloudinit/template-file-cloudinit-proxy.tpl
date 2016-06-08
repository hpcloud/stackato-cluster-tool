#cloud-config

bootcmd:
  # Update the ephemeral ports range to match the network ACL
  - sysctl net.ipv4.ip_local_port_range="${ephemeral_port_from} ${ephemeral_port_to}"
  # Create a user used by other nodes to download the provisioner scripts
  - useradd -m -s /bin/bash ${provisioner_repo_user}
  - echo '${provisioner_repo_user}:${provisioner_repo_password}' | chpasswd
  # Allow SSH password authentication from inside the network
  - sed -i -e "\$aMatch Address ${internal_network}\n\tPasswordAuthentication yes\n\tAllowUsers ${provisioner_repo_user}" /etc/ssh/sshd_config
  - service ssh restart

apt_proxy: ${apt_upstream_proxy}
apt_https_proxy: ${apt_upstream_proxy}
packages:
 - dos2unix

runcmd:
  - while [ ! -d ${provisioner_repo_location} ]; do echo "Waiting for ${provisioner_repo_location}"; sleep 5; done
  - find ${provisioner_repo_location} -type f -exec dos2unix {} \;
  - chmod u+x ${provisioner_repo_location}/configure-proxy.sh
  - ${provisioner_repo_location}/configure-proxy.sh "${provisioner_repo_location}/etc/polipo" "${http_proxy_port}" "${internal_network}" "${apt_upstream_proxy}" "${http_upstream_proxy}"
