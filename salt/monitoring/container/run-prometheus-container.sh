#! /bin/bash

cp prometheus.yml /tmp 
cp ../prometheus/rules.yml /tmp
docker run -p 9090:9090 -v /tmp/prometheus.yml:/etc/prometheus/prometheus.yml  -v /tmp/rules.yml:/etc/prometheus/rules.yml prom/prometheus
