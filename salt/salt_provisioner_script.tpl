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

# Workaround for the cases where the cloud providers are coming without repositories
# https://www.suse.com/support/kb/doc/?id=7022311
# Check if the deployment is executed in a cloud provider
grep -q 'provider: azure\|aws' /tmp/grains && CLOUD=1
if [[ $${QA_MODE} != 1 && $${CLOUD} == 1 && "${regcode}" == "" ]]; then
  zypper lr || sudo /usr/sbin/registercloudguest --force-new
fi

# Install salt if QA_MODE is False and salt is not already installed
# It will register in SCC to install salt if registration code is provided
[[ "${regcode}" != "" ]] && REGISTER="-d -r ${regcode}"
if [[ $${QA_MODE} != 1 && $${SALT} != 1 ]]; then
  sh /root/salt/install-salt-minion.sh $${REGISTER}
fi

# Recheck if salt-call is installed. If it's not available stop execution
which salt-call || exit 1

# Move salt grains to salt folder
mkdir -p /etc/salt;mv /tmp/grains /etc/salt || true

# Server configuration
sh /root/salt/deployment.sh || exit 1

# Salt formulas execution
if grep -q 'role:.*_node' /etc/salt/grains; then
  sh /root/salt/formula.sh || exit 1
fi

# QA additional tasks
if [[ $${QA_MODE} ]] && grep -q 'role: hana_node' /etc/salt/grains; then
  sh /root/salt/qa_mode/run_qa_mode.sh || exit 1
fi
