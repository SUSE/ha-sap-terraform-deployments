# Monitoring deploymenet for SHAP:

The monitoring module will deploy and install the required tools (grafana, prometheus) to monitor your SHAP stack (SAP HANA, HA cluster, etc).

The monitoring module will need an extra VM. The packages are the same from Uyuni/Suse manager, so we use the same pkg repository.

The terraform module follows the same conventions as other modules

* mandatory:

`monitored_services` this is a list containing the services to be monitored. Format: `HOST_IP:PORT`. Under the hood this var tell prometheus the IP and port where to scrape.

See tfvars.example
```
monitored_services = ["192.168.110.X:8001", "192.168.110.X+1:8001", "192.168.110.X:9100", "192.168.110.X+1:9100"]
```


If you want to disable monitoring for hosts, use:
`monitoring_enabled: false`


# Enable the SAP HANA database exporters

The SAP HANA database data is exported using the [hanadb_exporter](https://github.com/SUSE/hanadb_exporter) prometheus exporter.
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

# Enable the HA exporter

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

# Examples:

For an example look at [main.tf](../main.tf) file and `monitoring` module.
