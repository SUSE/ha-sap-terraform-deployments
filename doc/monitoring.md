# Monitoring


### Overview

The monitoring feature will install and configure all the tools required to monitor the various components of the HA SAP cluster (Pacemaker, Corosync, SBD, DRBD, SAP HANA, etc).

**Note:** an extra instance, hosting a Prometheus/Grafana server, will be provisioned.


### Usage

The monitoring stack is disabled by default.  
In order to enable it, you will need to set the set `monitoring_enabled` Terraform variable to `true`.

This configuration will create an additional VM with the chosen provider and install all the required packages in the monitored nodes.

The address of the Grafana dashboard will be made available in the final Terraform output.

### DRBD and Netweaver monitoring

If DRBD or Netweaver clusters are enabled setting the values `drbd_enabled` or `netweaver_enabled` to `true`, new clusters entries will be added to the dashboard automatically with the data of these 2 deployments (as far as `monitoring_enabled` is set to `true`).


### Prometheus metric exporters

These are the exporters installed in the cluster nodes, which provide metrics to be scraped by the Prometheus server:

- [ClusterLabs/ha_cluster_exporter](http://github.com/ClusterLabs/ha_cluster_exporter)
- [SUSE/hanadb_exporter](https://github.com/SUSE/hanadb_exporter)
- [prometheus/node_exporter](https://github.com/prometheus/node_exporter)

#### `ha_cluster_exporter`

In order to enable `ha_cluster_exporter` for each cluster node, the `cluster` pillar must be as follows:

```
cluster:
  // etc.
  ha_exporter: true
```

#### `hanadb_exporter`

In order to enable `hanadb_exporter` for each HANA node, the `hana` pillar entries must be modified as follows:

```
hana:
  nodes:
    - // etc.
      exporter:
        exposition_port: 9668 # http port where the data is exported
        user: SYSTEM # HANA db user
        password: YourPassword1234 # HANA db password
```

**Note**: SAP HANA already uses some ports in the 8000 range (specifically the port 80{instance number} where instance number usually is '00').


### Multi-cluster monitoring

To enable multiple clusters in our monitoring solution, you will need to manually apply some changes to the `/etc/prometheus/prometheus.yaml` configuration.

Each cluster is a different "job" grouping all the exporters (aka "targets") to scrape, so if you had two clusters you would have 2 jobs, e.g.:

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

You will find a dedicated cluster selector switch at the top of the Grafana dashboard.


### DRBD split-brain detection

DRBD has a hook mechanism to trigger some script execution when a split-brain occurs.  
We leverage this to let `ha_cluster_exporter` detect the split-brain status and record it.

In order to enable this, you'll need to activate the custom hook handler via pillars; in the [automatic DRBD pillar](../pillar_examples/automatic/drbd/drbd.sls), this is already configured for you and it will work OOTB.

The handler is just a simple shell script that will create a temporary file in `/var/run/drbd/splitbrain` when a split-brain is detected; `ha_cluster_exporter` will check for files in this directory and will expose dedicated Prometheus metrics accordingly.

After the split-brain is fixed, the temporary files must be removed manually: as long as these files exist, the exporter will continue reporting the split-brain occurrence.
