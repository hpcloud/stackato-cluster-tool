#cloud-config

# Does not work
# users:
#  - name: stackato
#    sudo: ['ALL=(ALL) NOPASSWD:ALL']

# Note: Cloudinit Stackato module doesn't work with unmodified Stackato image

bootcmd:
  # Bypass the microcloud setup
  - if [ ! -f /opt/stackato.conf ]; then cp /etc/init/stackato.conf /opt/stackato.conf; sed -i "/kato start/d" /etc/init/stackato.conf; fi
  # Increase the Redis start script timeout
  - sed -i "s/timeout 90/timeout 300/" /home/stackato/stackato/etc/firstboot/tasks/05-wait-for-config-redis.sh
  # Waiting for the APT Cacher
  - bash -c 'while ! nc -z $(echo ${apt_http_proxy} | sed "s/http[s]\?:\/\///" | tr ":" " "); do echo Waiting for APT Cacher on $(echo ${apt_http_proxy} | sed "s/http[s]\?:\/\///" |tr ":" " "); sleep 5; done'

apt_proxy: ${apt_http_proxy}
apt_https_proxy: ${apt_https_proxy}
packages:
  - sshpass

runcmd:
 - while ! sshpass -p${provisioner_repo_password} ssh -o StrictHostKeyChecking=no ${provisioner_repo_user}@${provisioner_repo_ip} test -d ${provisioner_repo_path}; do echo "Waiting for ${provisioner_repo_ip}:${provisioner_repo_path}"; sleep 5; done
 - sshpass -p${provisioner_repo_password} rsync -a ${provisioner_repo_user}@${provisioner_repo_ip}:${provisioner_repo_path}/ ${provisioner_repo_path}
 - chown -R root:root ${provisioner_repo_path}
 - chmod u+x ${provisioner_repo_path}/configure-node.sh
 - ${provisioner_repo_path}/configure-node.sh --core-ip "${core_ip}" --core-password "${core_password}" --cluster-hostname "${cluster_hostname}" --roles "${roles}" ${use_proxy_opt} --http-proxy "${http_proxy}" --https-proxy "${https_proxy}" --apt-http-proxy "${apt_http_proxy}" --apt-https-proxy "${apt_https_proxy}"
 - cp /opt/stackato.conf /etc/init/stackato.conf
