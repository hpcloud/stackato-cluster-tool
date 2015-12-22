#cloud-config
users:
   - name: stackato
     sudo: ALL=(ALL) NOPASSWD:ALL

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
 # - sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
 # Use the APT Cacher on the core node
 - echo 'Acquire::HTTP::Proxy "http://${core_ip}:3142";' > /etc/apt/apt.conf.d/01proxy
 - echo 'Acquire::HTTPS::Proxy "false";' >> /etc/apt/apt.conf.d/01proxy
 # Get the public key of the Core node (Passwordless ssh fron the core)
 - sshpass -p '${core_password}' ssh -o StrictHostKeyChecking=no stackato@${core_ip} cat /home/stackato/.ssh/id_rsa.pub >> /home/stackato/.ssh/authorized_keys
 # Try to attach the node to the Core until it works
 - su - stackato -c '/home/stackato/bin/kato op defer "node attach --enable ${roles} ${core_ip}" --run-as-root --post-start'
