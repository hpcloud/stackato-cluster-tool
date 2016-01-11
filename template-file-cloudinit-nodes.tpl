#cloud-config
users:
   - name: stackato
     sudo: ['ALL=(ALL) NOPASSWD:ALL']

apt_proxy: http://${core_ip}:3142
packages:
 - sshpass

bootcmd:
 # Waiting for the APT Cacher
 - bash -c 'while ! nc -z ${core_ip} 3142; do echo Waiting for APT Cacher on ${core_ip}; sleep 5; done'
 # Wait for the core node
 - bash -c 'while ! nc -z ${core_ip} 4222; do echo Waiting for core node on ${core_ip}; sleep 5; done'

# stackato:
#   nats:
#     ip: ${core_ip}
#   roles: ${roles}

runcmd:
 # Increase the Redis start script timeout
 - sed -i "s/timeout 90/timeout 300/" /home/stackato/stackato/etc/firstboot/tasks/05-wait-for-config-redis.sh
 # Passwordless sudo
 - echo "stackato ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
 # Disable SSH password authentication on the node
 - sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
 - service ssh reload
 # Change the password
 - echo "stackato:$(openssl rand -base64 32)" | chpasswd
 # Use the APT Cacher on the core node
 - echo 'Acquire::HTTP::Proxy "http://${core_ip}:3142";' > /etc/apt/apt.conf.d/01proxy
 - echo 'Acquire::HTTPS::Proxy "false";' >> /etc/apt/apt.conf.d/01proxy
 # Get the public key of the Core node (Passwordless ssh fron the core)
 - sshpass -p '${core_password}' ssh -o StrictHostKeyChecking=no stackato@${core_ip} cat /home/stackato/.ssh/id_rsa.pub >> /home/stackato/.ssh/authorized_keys
 # Inject the public key of the node in the Core node (Passwordless ssh from the node to the Core) when the key will be ready
 - su - stackato -c '/home/stackato/bin/kato op defer "version; sshpass -p ${core_password} ssh-copy-id -i /home/stackato/.ssh/id_rsa.pub stackato@${core_ip}; /home/stackato/bin/kato node attach --enable ${roles} ${core_ip}"  --run-as-root --post-start'
 # Try to attach the node to the Core until it works
 # - su - stackato -c '/home/stackato/bin/kato op defer "node attach --enable ${roles} ${core_ip}" --run-as-root --post-start'
 # Setup the HTTP Proxy
 - su - stackato -c '/home/stackato/bin/kato op defer "op upstream_proxy set ${core_ip}:8123" --run-as-root --post-start'
 - su - stackato -c '/home/stackato/bin/kato op defer "config set dea_ng environment/app_http_proxy http://${core_ip}:8123" --run-as-root --post-start'
 - su - stackato -c '/home/stackato/bin/kato op defer "config set dea_ng environment/app_https_proxy http://${core_ip}:8123" --run-as-root --post-start'
 - su - stackato -c '/home/stackato/bin/kato op defer "version; sudo /etc/init.d/polipo restart" --run-as-root --post-start'
 - echo "export http_proxy=http://${core_ip}:8123" >> /home/stackato/.bashrc
 - echo "export https_proxy=http://${core_ip}:8123" >> /home/stackato/.bashrc
