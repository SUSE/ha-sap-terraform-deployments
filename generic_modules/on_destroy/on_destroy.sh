#!/bin/bash

if ! SUSEConnect -s | grep -q "Not Registered"; then
  sudo /usr/bin/SUSEConnect -d
fi
