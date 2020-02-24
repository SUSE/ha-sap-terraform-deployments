# Deployement templates:

This doc is an invetory of common functional templates, use-cases of the deployment project.
This examples were used with KVM libvrt but the other providers will have the same vars or differ not significantly. 


- [Hana cluster (the simplest one)](hana_cluster)
- [ISCSI Server](ISCSI Server)
- [Monitoring hana cluster](Monitoring_hana_cluster)

( Not yet avail)
- NETWEAVER
- NETWEAVER Monitoring (need implementation)
- DRBD 

Additionally you need to set up pillars. In dev-mode we use mostly `automatic`. 
See https://github.com/SUSE/ha-sap-terraform-deployments/tree/master/pillar_examples#pillar-examples for more details.


# Hana cluster

```
qemu_uri = "qemu+ssh://MYUSER@MYSTEM/system"
base_image = "URL_TO_IMAGE"
iprange = "192.168.210.0/24"
hana_inst_media = "PATH TO INST_MEDIA"
host_ips = ["192.168.110.19", "192.168.110.20"]
reg_code = "MY_REG_CODE"
reg_email = "MY_EMAIL"
ha_sap_deployment_repo = "http://download.opensuse.org/repositories/network:/ha-clustering:/Factory/SLE_15/"
shared_storage_type = "shared-disk"
storage_pool           = "terraform"
```

# Monitoring hana cluster

To monitoring ha_cluster you need only 2 vars more then hana_cluster deployment.

```
monitoring_srv_ip = "yourIP"
monitoring_enabled = true
```

```
qemu_uri = "qemu+ssh://MYUSER@MYSTEM/system"
base_image = "URL_TO_IMAGE"
iprange = "192.168.210.0/24"
hana_inst_media = "PATH TO INST_MEDIA"
host_ips = ["192.168.110.19", "192.168.110.20"]
monitoring_srv_ip = "192.168.110.21"
monitoring_enabled = true
reg_code = "MY_REG_CODE"
reg_email = "MY_EMAIL"
ha_sap_deployment_repo = "http://download.opensuse.org/repositories/network:/ha-clustering:/Factory/SLE_15/"
shared_storage_type = "shared-disk"
storage_pool           = "terraform"
```

# ISCSI Server

```
qemu_uri = "qemu+ssh://MYUSER@MYSTEM/system"
base_image = "URL_TO_IMAGE"
iprange = "192.168.210.0/24"
hana_inst_media = "PATH TO INST_MEDIA"
host_ips = ["192.168.110.19", "192.168.110.20"]
reg_code = "YOUR_REG_CODE"
reg_email = "MY_EMAIL"
ha_sap_deployment_repo = "http://download.opensuse.org/repositories/network:/ha-clustering:/Factory/SLE_15/"
shared_storage_type = "iscsi"
iscs_srv_ip = "192.168.110.31"
storage_pool           = "terraform"
```

If you use a lower version then SLE15 of the `base_image`, you need to set `iscsi_image` to a sle15 image, since it doesn't work with lower version.
