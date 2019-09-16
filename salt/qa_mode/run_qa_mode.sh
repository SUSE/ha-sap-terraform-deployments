#!/bin/bash -xe

# We need to export HOST with the new hostname set by Salt
# Otherwise, hwcct will error out.
export HOST=$(hostname)

# Execute qa state file
salt-call --local --file-root=/root/salt/ \
    --log-level=info \
    --log-file=/tmp/salt-qa.log \
    --log-file-level=info \
    --retcode-passthrough \
    --force-color state.apply qa_mode || exit 1
