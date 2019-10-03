#!/bin/bash -xe

mv /tmp/salt /root || true

# Check is qa_mode is enable
grep -q 'qa_mode: true' /tmp/grains && QA_MODE=1

# Disable colors for QA_MODE
if [[ $${QA_MODE} ]]; then
  SALT_DIR='/root/salt/'
  SALT_CALL_FILES="$${SALT_DIR}deployment.sh $${SALT_DIR}formula.sh $${SALT_DIR}qa_mode/run_qa_mode.sh"
  for file in $${SALT_CALL_FILES}; do
    sed -i 's/force-color/no-color/g' $${file}
  done
fi

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
if [[ $${QA_MODE} ]] && grep -q 'role: hana_node' /etc/salt/grains; then
  sh /root/salt/qa_mode/run_qa_mode.sh || exit 1
fi
