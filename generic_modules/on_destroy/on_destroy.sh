#!/bin/bash

if [[ ! $(SUSEConnect -s | grep "Not Registered") ]];then
  sudo /usr/bin/SUSEConnect -d
fi
