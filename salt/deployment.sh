#!/bin/bash

salt-call --local --file-root=/root/salt/ --log-level=info --retcode-passthrough --force-color state.highstate
