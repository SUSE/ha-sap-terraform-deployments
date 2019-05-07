#!/bin/bash -xe

# SCC Registration to install salt-minion

if grep -q 'role: iscsi_srv' /etc/salt/grains; then
  sh /root/salt/install-salt-minion.sh -r ${regcode}
elif [[ ! -e /usr/bin/salt-minion ]]; then
  sh /root/salt/install-salt-minion.sh -d -r ${regcode}
fi

# Server configuration
sh /root/salt/deployment.sh

# Salt formulas execution
if grep -q 'role: hana_node' /etc/salt/grains; then
  sh /root/salt/formula.sh
fi
