#!/bin/bash -xe

exec > /tmp/init_server.log 2>&1

# Wait for the provisioner file step in Terraform
while [[ ! -d "/root/salt/" ]];do
  echo "Waiting for Salt directory..."
  sleep 5
done

if grep -q 'role: "iscsi_srv"' /tmp/grains; then
  sh /root/salt/install-salt-minion.sh -r ${regcode}
elif [[ ! -e /usr/bin/salt-minion ]]; then
  sh /root/salt/install-salt-minion.sh -d -r ${regcode}
fi
 
mkdir -p /etc/salt; mv /tmp/grains /etc/salt/

# Server configuration
sh /root/salt/deployment.sh

# Salt formulas execution
[[ -d /srv/salt ]] && sh /root/salt/formula.sh
