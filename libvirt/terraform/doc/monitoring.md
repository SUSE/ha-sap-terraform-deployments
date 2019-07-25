# Monitoring deploymenet for SHAP:

The monitoring module will deploy and install the required tools (grafana, prometheus) to monitor your SHAP stack (SAP HANA, HA cluster, etc).

The monitoring module will need an extra VM. The packages are the same from Uyuni/Suse manager, so we use the same pkg repository.

The terraform module follows the same conventions as other modules

# Enable the monitoring module:

1) Add the IP of your monitoring host in the terraform.tfvars
```monitoring_srv_ip = "192.168.XXX.Y+3"```

2) add the monitoring module to your main.tf

See main.tf.example for the monitoring module definition.

once added, do `terraform apply`.

3) enable the prometheus exporter in order to gather data, see below

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

# Examples:

For an example look at [main.tf](../main.tf) file and `monitoring` module.
