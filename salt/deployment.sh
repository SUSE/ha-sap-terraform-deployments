#!/bin/bash

salt-call --local --file-root=/root/salt/ \
    --pillar-root=/root/salt/iscsi_srv/files/pillar/ \
    --log-level=info \
    --log-file=/tmp/salt-deployment.log \
    --log-file-level=all \
    --retcode-passthrough \
    --force-color state.highstate
