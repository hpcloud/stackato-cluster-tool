#cloud-config
users:
   - name: stackato
     sudo: ALL=(ALL) NOPASSWD:ALL

bootcmd:
 - sed -i "s/timeout 90/timeout 300/" /home/stackato/stackato/etc/firstboot/tasks/05-wait-for-config-redis.sh

runcmd:
 - su - stackato -c '/home/stackato/bin/kato op defer "node rename ${cluster_hostname} --no-restart" --run-as-root --post-start'
 - su - stackato -c '/home/stackato/bin/kato op defer "node setup core api.${cluster_hostname}" --run-as-root --post-start'
