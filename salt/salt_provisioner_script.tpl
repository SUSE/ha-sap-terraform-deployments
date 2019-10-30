#!/bin/bash -xe

mv /tmp/salt /root || true

# Check if qa_mode is enabled
grep -q 'qa_mode: true' /tmp/grains && QA_MODE=1

# Check if salt-call is installed
which salt-call > /dev/null 2>&1 && SALT=1

# Disable colors for QA_MODE
if [[ $${QA_MODE} ]]; then
  SALT_DIR='/root/salt/'
  SALT_CALL_FILES="$${SALT_DIR}deployment.sh $${SALT_DIR}formula.sh $${SALT_DIR}qa_mode/run_qa_mode.sh"
  for file in $${SALT_CALL_FILES}; do
    sed -i 's/force-color/no-color/g' $${file}
  done
fi

# SCC Registration to install salt-minion
# The iSCSI server won't be de-registered as it is needed to install some additional packages.
if grep -Eq 'role: iscsi_srv|role: drbd_node' /tmp/grains; then
  sh /root/salt/install-salt-minion.sh -r ${regcode}

# If salt-minion is not included in image, system is registered to install salt-minion 
# and de-registered afterwards unless if QA_MODE is set or salt already installed.
elif [[ $${QA_MODE} != 1 && $${SALT} != 1 ]]; then
  sh /root/salt/install-salt-minion.sh -d -r ${regcode}
fi

# Move salt grains to salt folder
mkdir -p /etc/salt;mv /tmp/grains /etc/salt || true

# Server configuration
sh /root/salt/deployment.sh || exit 1

# Salt formulas execution
if grep -Eq 'role: hana_node|role: drbd_node' /etc/salt/grains; then
  sh /root/salt/formula.sh || exit 1
fi

# QA additional tasks
if [[ $${QA_MODE} ]] && grep -q 'role: hana_node' /etc/salt/grains; then
  sh /root/salt/qa_mode/run_qa_mode.sh || exit 1
fi
