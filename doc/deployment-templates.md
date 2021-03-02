# Deployment templates

This document is an inventory of functional templates for common use-cases of the deployment project.
The following examples refer to the libvirt Terraform provider, but they may be used for the other providers as well: there are no significant differences for the most common settings.


- Hana cluster (the simplest one)
- Monitoring hana cluster
- ISCSI Server
- NETWEAVER

Not implementd yet:
- NETWEAVER Monitoring (need implementation)

Additionally you need to set up pillars. In dev-mode we use mostly `automatic`.
See https://github.com/SUSE/ha-sap-terraform-deployments/tree/master/pillar_examples#pillar-examples for more details.

The values of ipranges and ips needs are as example there. You will need to adapt accordingly your network configuration.


# hana cluster

```
qemu_uri = "qemu+ssh://MYUSER@MYSTEM/system"
pre_deployment = true
base_image = "URL_TO_IMAGE"
iprange = "192.168.210.0/24"
hana_inst_master = "PATH TO INST_MEDIA"
host_ips = ["192.168.110.19", "192.168.110.20"]
reg_code = "MY_REG_CODE"
reg_email = "MY_EMAIL"
# To auto detect the SLE version
ha_sap_deployment_repo = "http://download.opensuse.org/repositories/network:/ha-clustering:/Factory/"
# Specific SLE version used in all the created machines
ha_sap_deployment_repo = "http://download.opensuse.org/repositories/network:/ha-clustering:/Factory/SLE_15/"
shared_storage_type = "shared-disk"
storage_pool           = "terraform"
```

# monitoring hana cluster

To monitoring the HANA cluster need only 2 vars more than the simple HANA deployment.


`monitoring_srv_ip = "yourIP"` and `monitoring_enabled = true`

```
qemu_uri = "qemu+ssh://MYUSER@MYSTEM/system"
pre_deployment = true
base_image = "URL_TO_IMAGE"
iprange = "192.168.210.0/24"
hana_inst_master = "PATH TO INST_MEDIA"
host_ips = ["192.168.110.19", "192.168.110.20"]
monitoring_srv_ip = "192.168.110.21"
monitoring_enabled = true
reg_code = "MY_REG_CODE"
reg_email = "MY_EMAIL"
# To auto detect the SLE version
ha_sap_deployment_repo = "http://download.opensuse.org/repositories/network:/ha-clustering:/Factory/"
# Specific SLE version used in all the created machines
ha_sap_deployment_repo = "http://download.opensuse.org/repositories/network:/ha-clustering:/Factory/SLE_15/"
shared_storage_type = "shared-disk"
storage_pool           = "terraform"
```

# iscsi server

```
qemu_uri = "qemu+ssh://MYUSER@MYSTEM/system"
pre_deployment = true
base_image = "URL_TO_IMAGE"
iprange = "192.168.210.0/24"
hana_inst_master = "PATH TO INST_MEDIA"
host_ips = ["192.168.110.19", "192.168.110.20"]
reg_code = "YOUR_REG_CODE"
reg_email = "MY_EMAIL"
# To auto detect the SLE version
ha_sap_deployment_repo = "http://download.opensuse.org/repositories/network:/ha-clustering:/Factory/"
# Specific SLE version used in all the created machines
ha_sap_deployment_repo = "http://download.opensuse.org/repositories/network:/ha-clustering:/Factory/SLE_15/"
shared_storage_type = "iscsi"
iscsi_srv_ip = "192.168.110.31"
iscsi_image = "SLE15 IMAGE"
storage_pool           = "terraform"
```

NOTE: ISCSI server works with a sle15 or higher image

# Netweaver

```
qemu_uri = "qemu+ssh://MYUSER@MYSTEM/system"
pre_deployment = true
base_image = "URL_TO_IMAGE"
iprange = "192.168.210.0/24"
hana_inst_master = "PATH TO INST_MEDIA"
host_ips = ["192.168.110.19", "192.168.110.20"]
reg_code = "MY_REG_CODE"
reg_email = "MY_EMAIL"
# To auto detect the SLE version
ha_sap_deployment_repo = "http://download.opensuse.org/repositories/network:/ha-clustering:/Factory/"
# Specific SLE version used in all the created machines
ha_sap_deployment_repo = "http://download.opensuse.org/repositories/network:/ha-clustering:/Factory/SLE_15/"
shared_storage_type = "shared-disk"
storage_pool           = "terraform"
netweaver_inst_media = "PATH INST MEDIA"
netweaver_nfs_share      = "192.168.110.201:/HA1"
netweaver_enabled        = true
drbd_enabled           = true
drbd_shared_storage_type = "shared-disk"
drbd_ips               = ["192.168.110.23", "192.168.110.22"]
nw_ips                 = ["192.168.110.24", "192.168.110.25", "192.168.110.26", "192.168.110.27"]
nw_virtual_ips          = ["192.168.110.31", "192.168.110.30", "192.168.110.29", "192.168.119.28"]
```

For libvirt you need drbd
