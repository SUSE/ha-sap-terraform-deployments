#!/bin/bash -xe

mv /tmp/salt /root || true

# SCC Registration to install salt-minion

# The iSCSI server won't be de-registered as it needs to install some additional packages.
if grep -q 'role: iscsi_srv' /tmp/grains; then
  sh /root/salt/install-salt-minion.sh -r ${regcode}

# System is registered to install salt-minion and de-registered afterwards
# if the variable install_salt_minion is true
elif grep -q 'install_salt_minion: 1' /tmp/grains; then
  sh /root/salt/install-salt-minion.sh -d -r ${regcode}
fi

mkdir -p /etc/salt;mv /tmp/grains /etc/salt || true

# Server configuration
sh /root/salt/deployment.sh || exit 1

# Salt formulas execution
if grep -q 'role: hana_node' /etc/salt/grains; then
  sh /root/salt/formula.sh || exit 1
fi
