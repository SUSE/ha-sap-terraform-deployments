#! /bin/bash
docker stop grafana || true && docker rm grafana || true
docker run -p 3000:3000 --name grafana -v "$PWD"/../provisioning/:/etc/grafana/provisioning -e "GF_provisioning=/provisioning" grafana/grafa
