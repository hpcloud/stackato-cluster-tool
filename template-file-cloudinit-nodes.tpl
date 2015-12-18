#cloud-config
users:
   - name: stackato
     sudo: ALL=(ALL) NOPASSWD:ALL

bootcmd:
 - sed -i "s/timeout 90/timeout 300/" /home/stackato/stackato/etc/firstboot/tasks/05-wait-for-config-redis.sh

# stackato:
#   nats:
#     ip: ${core_ip}
#   roles: ${roles}

runcmd:
 - su - stackato -c '/home/stackato/bin/kato op defer "node attach -e ${roles} ${core_ip}" --run-as-root --post-start'
