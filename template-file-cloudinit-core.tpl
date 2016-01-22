#cloud-config

# Does not work
# users:
#  - name: stackato
#    sudo: ['ALL=(ALL) NOPASSWD:ALL']

bootcmd:
  # Increase the Redis start script timeout
  - sed -i "s/timeout 90/timeout 300/" /home/stackato/stackato/etc/firstboot/tasks/05-wait-for-config-redis.sh
  # Passwordless sudo before the Stackato firstboot
  - echo "stackato ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

runcmd:
 # Start the APT Cacher
 # Logs: docker exec -it apt-cacher-ng tail -f /var/log/apt-cacher-ng/apt-cacher.log
 #- docker run --name apt-cacher-ng -d --publish 3142:3142 --volume /srv/docker/apt-cacher-ng:/var/cache/apt-cacher-ng quay.io/sameersbn/apt-cacher-ng
 - service apt-cacher-ng start
 # Update the password of the stackato account
 - echo stackato:${core_password} | chpasswd
 # Disable SSH password authentication on the core
 # /!\ Don't do that! otherwise node will not be able to transfer SSH keys
 # - sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
 # - service ssh reload
 # Disable SSH StrictHostKeyChecking (otherwise SSH will prompt for the check)
 - su - stackato -c 'echo -e "Host 10.0.*.*\n\tStrictHostKeyChecking no" > /home/stackato/.ssh/config'
 # Setup the core node
 - su - stackato -c '/home/stackato/bin/kato op defer "node rename ${cluster_hostname} --no-restart" --run-as-root --post-start'
 - su - stackato -c '/home/stackato/bin/kato op defer "node setup core api.${cluster_hostname}" --run-as-root --post-start'
