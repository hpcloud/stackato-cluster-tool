#cloud-config

packages:
 - dos2unix

# Does not work
# users:
#  - name: stackato
#    sudo: ['ALL=(ALL) NOPASSWD:ALL']

bootcmd:
  # Bypass the microcloud setup
  - cp /etc/init/stackato.conf /opt/
  - sed -i "/kato start/d" /etc/init/stackato.conf
  # Increase the Redis start script timeout
  - sed -i "s/timeout 90/timeout 300/" /home/stackato/stackato/etc/firstboot/tasks/05-wait-for-config-redis.sh
  # Passwordless sudo before the Stackato firstboot
  - echo "stackato ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

runcmd:
 - while [ ! -d ${stackato_automation_path} ]; do echo "Waiting for ${stackato_automation_path}"; sleep 5; done
 - find ${stackato_automation_path} -type f -exec dos2unix {} \;
 - chmod u+x ${stackato_automation_path}/configure-core.sh
 - ${stackato_automation_path}/configure-core.sh ${core_password} ${cluster_hostname} ${roles}
 - mv /opt/stackato.conf /etc/init/
