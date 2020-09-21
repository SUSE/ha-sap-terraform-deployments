# Monitoring


### Overview

The monitoring feature will install and configure all the tools required to monitor the various components of the HA SAP cluster (Pacemaker, Corosync, SBD, DRBD, SAP HANA, etc).

**Note:** an extra instance, hosting a Prometheus/Grafana/Loki server, will be provisioned.


### Usage

The monitoring stack is disabled by default.  
In order to enable it, you will need to set the set `monitoring_enabled` Terraform variable to `true`.

This configuration will create an additional VM with the chosen provider and install all the required packages in the monitored nodes.

### Accessing the Dashboards

The public IP address of the monitoring instance will be made available in the final Terraform output. Dashboards can be then accessed by specifying the default HTTP ports for each services:
```
Grafana:    http://<monitoring_public_ip>:3000/
Prometheus: http://<monitoring_public_ip>:9090/
```

### Prometheus metric exporters

These are the exporters installed in the cluster nodes, which provide metrics to be scraped by the Prometheus server:

- [prometheus/node_exporter](https://github.com/prometheus/node_exporter)
- [ClusterLabs/ha_cluster_exporter](http://github.com/ClusterLabs/ha_cluster_exporter)
- [SUSE/hanadb_exporter](https://github.com/SUSE/hanadb_exporter)
- [SUSE/sap_host_exporter](https://github.com/SUSE/sap_host_exporter)


### Multi-cluster monitoring

To enable multiple clusters in our monitoring solution, we have made some changes to the `/etc/prometheus/prometheus.yaml` configuration.

We leverage the `job_name` settings to group all the exporters (a.k.a. scraping targets) by their cluster, so if you had two clusters you would have one job each, e.g.:

```
scrape_configs:
  - job_name: hacluster-01
    static_configs:
      - targets:
        - "192.168.110.19:9668" # 9668: hanadb exporter port
        - "192.168.110.20:9668" # 9668: hanadb exporter port
        - "192.168.110.19:9100" # 9100: node exporter port
        - "192.168.110.20:9100" # 9100: node exporter port
        - "192.168.110.19:9664" # 9664: ha_cluster_exporter metrics
        - "192.168.110.20:9664" # 9664: ha_cluster_exporter metrics


  - job_name: hacluster-02
    static_configs:
      - targets:
        - "10.162.32.117:9668" # 9668: hanadb exporter port
        - "10.162.32.238:9668" # 9668: hanadb exporter port
        - "10.162.32.117:9100" # 9100: node exporter port
        - "10.162.32.238:9100" # 9100: node exporter port
        - "10.162.32.117:9664" # 9664: ha_cluster_exporter metrics
        - "10.162.32.238:9664" # 9664: ha_cluster_exporter metrics
```

This will add a `job` label in all the Prometheus metrics, in this example `job="hacluster-01"` and `job="hacluster-02"`.

We leverage this to implement a cluster selector switch at the top of the Multi-Cluster Grafana dashboard.


### DRBD and Netweaver monitoring

If DRBD or Netweaver clusters are enabled setting the values `drbd_enabled` or `netweaver_enabled` to `true`, new clusters entries will be added to the dashboard automatically with the data of these 2 deployments (as far as `monitoring_enabled` is set to `true`).


### DRBD split-brain detection

DRBD has a hook mechanism to trigger some script execution when a split-brain occurs.  
We leverage this to let `ha_cluster_exporter` detect the split-brain status and record it.

In order to enable this, you'll need to activate the custom hook handler via pillars; in the [automatic DRBD pillar](../pillar_examples/automatic/drbd/drbd.sls), this is already configured for you and it will work OOTB.

The handler is just a simple shell script that will create a temporary file in `/var/run/drbd/splitbrain` when a split-brain is detected; `ha_cluster_exporter` will check for files in this directory and will expose dedicated Prometheus metrics accordingly.

After the split-brain is fixed, the temporary files must be removed manually: as long as these files exist, the exporter will continue reporting the split-brain occurrence.


### Logging

When monitoring is enabled, centralized logging will be provisioned via Loki, a log aggregator.

You can browse the systemd journal of all the nodes in the Grafana Explorer, by selecting the `Loki` datasource.
