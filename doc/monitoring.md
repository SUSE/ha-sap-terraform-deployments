# Monitoring

# Highlevel description

The monitoring feature will deploy and install the required tools (grafana, prometheus) to monitor your HA and SAP stack (SAP HANA, HA cluster, etc).
Additionally with different variables you can install and control the various metrics exporters.

**The monitoring feature will need an extra instance, that will host grafana/prometheus server for the dashboard visualisation.**

# How to use the monitoring solution

In order to enable/disable (disabled by default) the monitoring feature, you need to:

* libvirt: set `monitoring_enabled` variable to true/false (or just remove or add the `monitoring` module in your main.tf)

* azure/aws/gcp: set `monitoring_enabled` variable to true/false.

This configuration will create an additional VM in the chosen provider and install all the required packages in the monitored hosts.
IP address to the Grafana dashboard will be available in the final terraform output.

`NOTE`: In future monitoring in cloud providers are going to be refactored and unified later with module similar to libvirt see https://github.com/SUSE/ha-sap-terraform-deployments/issues/107

# Hosts Exporters

Currently supported exporters:

- [Node exporter](https://github.com/prometheus/node_exporter)
- SAP-HANA database exporter
- HA Cluster exporter (hawk-apiserver)

# Multi-cluster monitoring:

For enabling multi-cluster in prometheus and in our monitoring solution, you need to follow the schema in `/etc/prometheus/prometheus.yaml`.

Each cluster is a different jobname. So if you have 2 cluster you will add 2 jobnames. like :

```
scrape_configs:
  - job_name: hacluster-01
    static_configs:
      - targets:
        - "192.168.110.19:8001" # 8001: hanadb exporter port
        - "192.168.110.20:8001" # 8001: hanadb exporter port
        - "192.168.110.19:9100" # 9100: node exporter port
        - "192.168.110.20:9100" # 9100: node exporter port
        - "192.168.110.19:9002" # 9002: ha_cluster_exporter metrics
        - "192.168.110.20:9002" # 9002: ha_cluster_exporter metrics


  - job_name: hacluster-02
    static_configs:
      - targets:
        - "10.162.32.117:8001" # 8001: hanadb exporter port
        - "10.162.32.238:8001" # 8001: hanadb exporter port
        - "10.162.32.117:9100" # 9100: node exporter port
        - "10.162.32.238:9100" # 9100: node exporter port
        - "10.162.32.117:9002" # 9002: ha_cluster_exporter metrics
        - "10.162.32.238:9002" # 9002: ha_cluster_exporter metrics
```

This will add in prometheus a label `job="hacluster-01` and  `job="hacluster-01`. In the grafana dashboard you will have a special switch on the top to switch clusters.



# Drbd splitbrain metric enablement.

In order to activate the metric for detecting the splitbrain occuring on drbd, you need to activate the custom handler via pillars.

In the automatic pillar `drdb` directory this is already done.

The handler will create a temporary file, which the `ha_cluster_exporter` will convert to a metric split brain.

After the split brain occurs, the sysadmin/user should remove the file manually and taking other action on drbd.

If the file persist, the ha_expoerter will always detect the splitbrain mechanism.



### SAP HANA database exporter

The SAP HANA database data is exporter using the [hanadb_exporter](https://github.com/SUSE/hanadb_exporter) prometheus exporter.
In order to enable the exporters for each HANA database the `hana` pillar entries must be modified.

Here an example:

```
hana:
  nodes:
    - host: {{ grains['name_prefix'] }}01
      sid: prd
      instance: 00
      password: YourPassword1234
      # Any other additional data
      exporter:
        exposition_port: 8001 # http port where the data is exported
        user: SYSTEM # HANA db user
        password: YourPassword1234 # HANA db password
```

**Attention**: SAP HANA already uses some ports in the 8000 range (specifically the port 80{instance number} where instance number usually is '00').


### HA Cluster exporter

The HA Prometheus metrics are exported using the hawk-apiserver [hawk-apiserver](https://github.com/ClusterLabs/hawk-apiserver).
In order to enable the exporter for each cluster node `cluster` pillar entries must be modified.

Here an example:

```
cluster:
  name: 'hacluster'
  init: 'hana01'
  interface: 'eth1'
  watchdog:
    module: softdog
    device: /dev/watchdog
  sbd:
    device: '/dev/vdc'
  ntp: pool.ntp.org
  sshkeys:
    overwrite: true
    password: linux
  resource_agents:
    - SAPHanaSR
  ha_exporter: true
```
