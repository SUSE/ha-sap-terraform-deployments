#!/bin/bash

salt-call --local \
    --module-dir=/srv/salt/_modules \
    --states-dir=/srv/salt/_states \
    --log-level=info \
    --log-file=/tmp/salt-formula.log \
    --log-file-level=all \
    --retcode-passthrough \
    --force-color state.highstate
