#!/bin/bash

salt-call --local --module-dir=/srv/salt/_modules --states-dir=/srv/salt/_states --log-level=info --retcode-passthrough --force-color state.highstate
