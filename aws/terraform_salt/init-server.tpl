#!/bin/bash -xe

exec > /tmp/init_server.log 2>&1

[[ ${QA_MODE} == true ]] && REGCODE=${QA_REG_CODE}

# Wait for the provisioner file step in Terraform
while [[ ! -d "/root/salt/" ]];do
  echo "Waiting for Salt directory..."
  sleep 5
done

# QA mode = false and salt-minion not installed
if [[ ${QA_MODE} == false ]] && [[ ! -e /usr/bin/salt-minion ]]; then
    sh /root/salt/install-salt-minion.sh -d -r $REGCODE
# QA mode = true, salt-minion have to be installed
else
    # Keep the iSCSI server registered because additionals packages are needed
    if grep -q 'role: "iscsi_srv"' /tmp/grains; then
        sh /root/salt/install-salt-minion.sh -r $REGCODE
    else
    # Register the system to install the salt-minion, then unregister it for 
    # using preinstalled packages.
        sh /root/salt/install-salt-minion.sh -d -r $REGCODE
    fi
    mv /tmp/grains /etc/salt/
fi

# Server configuration
sh /root/salt/deployment.sh

# Salt formulas execution
[[ -d /srv/salt ]] && sh /root/salt/formula.sh
