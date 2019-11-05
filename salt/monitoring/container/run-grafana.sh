#! /bin/bash

docker run -p 3000:3000 --name grafana-host -v "$PWD"/../provisioning/:/etc/grafana/provisioning -e "GF_provisioning=/provisioning" grafana/grafana
