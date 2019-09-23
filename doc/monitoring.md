# Monitoring

# Highlevel description:

The monitoring feature will deploy and install the required tools (grafana, prometheus) to monitor your HA and SAP stack (SAP HANA, HA cluster, etc).
Additionally with different variables you can install and control the various metrics exporters.

The monitoring feature will need an extra instance, that will host grafana/prometheus server for the dashboard visualisation.

# How to use the monitoring solution:

In order to enable disable the monitoring feature, you need to:

* libvirt: remove or add the `monitoring` module in your main.tf

* azure: for azure cloud we deploy by default the monitoring solution. 

`NOTE`: In future (azure and other cloud provider) they will be refactored and unified later with module similar to libvirt see https://github.com/SUSE/ha-sap-terraform-deployments/issues/107


# Variable specification:

`monitoring_enabled` default False. This variable will install all different supported exporters to the hosts. 
See the list of supported exporter for more details.

# Hosts Exporters

Currently supported exporters:

- SAP-HANA database exporter
- HA Cluster exporter (hawk-apiserver)

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
  ha_exporter:
    exposition_port: 9001
```
