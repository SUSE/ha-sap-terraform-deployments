#!/bin/bash

if [[ ! `SUSEConnect -s | grep "Not Registered"` ]];then
  /usr/bin/SUSEConnect -d
fi
