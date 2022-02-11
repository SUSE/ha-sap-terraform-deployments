#!/bin/bash

if ! SUSEConnect -s | grep -q "Not Registered"; then
  if [ -f /usr/sbin/registercloudguest ]; then
    /usr/sbin/registercloudguest --clean
  else
    /usr/bin/SUSEConnect -d
  fi
fi
