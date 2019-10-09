#!/bin/bash -xe

salt-call --local --file-root=/root/salt \
    --log-level=info \
    --log-file=/tmp/salt-pre-installation.log \
    --log-file-level=all \
    --retcode-passthrough \
    --force-color state.apply pre_installation || exit 1

salt-call --local \
    --pillar-root=/root/salt/pillar/ \
    --log-level=info \
    --log-file=/tmp/salt-deployment.log \
    --log-file-level=all \
    --retcode-passthrough \
    --force-color state.highstate || exit 1
