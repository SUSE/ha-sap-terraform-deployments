#!/bin/bash -xe

# Registration for install salt-minion only

if grep -q 'role: iscsi_srv' /tmp/grains; then
  sh /root/salt/install-salt-minion.sh -r ${regcode}
elif [[ ! -e /usr/bin/salt-minion ]]; then
  sh /root/salt/install-salt-minion.sh -d -r ${regcode}
fi

mkdir -p /etc/salt; mv /tmp/grains /etc/salt/

# Server configuration
sh /root/salt/deployment.sh

# Salt formulas execution
if grep -q 'role: hana_node' /etc/salt/grains; then
  sh /root/salt/formula.sh
fi
