#!/bin/bash -xe

salt-call --local \
    --log-level=info \
    --log-file=/tmp/salt-formula.log \
    --log-file-level=debug \
    --retcode-passthrough \
    --force-color state.highstate || exit 1
