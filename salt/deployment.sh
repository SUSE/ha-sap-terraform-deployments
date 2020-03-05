#!/bin/bash -xe

# Execute the states within /root/salt/pre_installation
# This first execution is done to configure the salt minion and install the iscsi formula
salt-call --local --file-root=/root/salt \
    --log-level=info \
    --log-file=/tmp/salt-pre-installation.log \
    --log-file-level=debug \
    --retcode-passthrough \
    --force-color state.apply pre_installation || exit 1

# Execute the states defined in /root/salt/top.sls
# This execution is done to pre configure the cluster nodes, the support machines and install the formulas
salt-call --local \
    --pillar-root=/root/salt/pillar/ \
    --log-level=info \
    --log-file=/tmp/salt-deployment.log \
    --log-file-level=debug \
    --retcode-passthrough \
    --force-color state.highstate saltenv=predeployment || exit 1
