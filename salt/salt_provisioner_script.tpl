#!/bin/bash -xe

mv /tmp/salt /root || true

# SCC Registration to install salt-minion

if grep -q 'role: iscsi_srv' /tmp/grains; then
  sh /root/salt/install-salt-minion.sh -r ${regcode}
elif [[ ! -e /usr/bin/salt-minion ]]; then
  sh /root/salt/install-salt-minion.sh -d -r ${regcode}
fi

mkdir -p /etc/salt;mv /tmp/grains /etc/salt || true

# Server configuration
sh /root/salt/deployment.sh || exit 1

# Salt formulas execution
if grep -q 'role: hana_node' /etc/salt/grains; then
  sh /root/salt/formula.sh || exit 1
fi

# QA additional tasks
if grep -q 'qa_mode: true' /etc/salt/grains && grep -q 'role: hana_node' /etc/salt/grains; then
  sh /root/salt/qa_mode/run_qa_mode.sh || exit 1
fi
