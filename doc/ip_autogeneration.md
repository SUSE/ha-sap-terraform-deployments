# IP addresses auto generation

In order to facilitate the configuration of the project, the IP addresses of the machines can be auto generated, based on the used network address range. To use the auto generation, just don't use any of the variables of the project that are used to set the address to the machines (e.g. `hana_ips`, `hana_cluster_vip`, `netweaver_ips`, etc)

**Note:** If you are specifying the IP addresses manually, make sure these are valid IP addresses. They should not be currently in use by existing instances. In case of shared account usage in cloud providers, it is recommended to set unique addresses with each deployment to avoid using same addresses.

## AWS

AWS has a pretty specific way of managing the addresses. Due to its architecture, each of the machines in a cluster must be in a different subnet to have HA capabilities. Besides that, the Virtual addresses must be outside of VPC address range too.

Example based on `10.0.0.0/16` address range (VPC address range) and `192.168.1.0/24` as `virtual_address_range` (the default value):

| Name | Substituted variable | Addresses | Comments |
| :---: | :---: | :----: | :---: |
| Iscsi server | `iscsi_srv_ip` | `10.0.0.4` ||
| Monitoring | `monitoring_srv_ip` | `10.0.0.5` ||
| Hana ips | `hana_ips` | `10.0.1.10`, `10.0.2.11` ||
| Hana cluster vip | `hana_cluster_vip` | `192.168.1.10` | Only used if HA is enabled in HANA |
| Hana cluster vip secondary | `hana_cluster_vip_secondary` | `192.168.1.11` | Only used if the Active/Active setup is used |
| DRBD ips | `drbd_ips` | `10.0.5.20`, `10.0.6.21` ||
| DRBD cluster vip | `drbd_cluster_vip` | `192.168.1.20` ||
| Netweaver ips | `netweaver_ips` | `10.0.3.30`, `10.0.4.31`, `10.0.3.32`, `10.0.4.33` | Addresses for the ASCS, ERS, PAS and AAS. The sequence will continue if there are more AAS machines |
| Netweaver virtual ips | `netweaver_virtual_ips` | `192.168.1.30`, `192.168.1.31`, `192.168.1.32`, `192.168.1.33` | The last number of the address will match with the regular address |

## Azure

Example based on `10.74.0.0/16` vnet address range and `10.74.0.0/24` subnet address range:

| Name | Substituted variable | Addresses | Comments |
| :---: | :---: | :----: | :---: |
| Iscsi server | `iscsi_srv_ip` | `10.74.0.4` ||
| Monitoring | `monitoring_srv_ip` | `10.74.0.5` ||
| Hana ips | `hana_ips` | `10.74.0.10`, `10.74.0.11` ||
| Hana cluster vip | `hana_cluster_vip` | `10.74.0.12` | Only used if HA is enabled in HANA |
| Hana cluster vip secondary | `hana_cluster_vip_secondary` | `10.74.0.13` | Only used if the Active/Active setup is used |
| DRBD ips | `drbd_ips` | `10.74.0.20`, `10.74.0.21` ||
| DRBD cluster vip | `drbd_cluster_vip` | `10.74.0.22` ||
| Netweaver ips | `netweaver_ips` | `10.74.0.30`, `10.74.0.31`, `10.74.0.32`, `10.74.0.33` | Addresses for the ASCS, ERS, PAS and AAS. The sequence will continue if there are more AAS machines |
| Netweaver virtual ips | `netweaver_virtual_ips` | `10.74.0.34`, `10.74.0.35`, `10.74.0.36`, `192.168.135.37` | The 1st virtual address will be the next in the sequence of the regular Netweaver addresses |


## GCP

Example based on `10.0.0.0/24` VPC address range. The virtual addresses must be outside of the VPC address range.

| Name | Substituted variable | Addresses | Comments |
| :---: | :---: | :----: | :---: |
| Iscsi server | `iscsi_srv_ip` | `10.0.0.4` ||
| Monitoring | `monitoring_srv_ip` | `10.0.0.5` ||
| Hana ips | `hana_ips` | `10.0.0.10`, `10.0.0.11` ||
| Hana cluster vip | `hana_cluster_vip` | `10.0.2.12` | Only used if HA is enabled in HANA |
| Hana cluster vip secondary | `hana_cluster_vip_secondary` | `10.0.1.13` | Only used if the Active/Active setup is used |
| DRBD ips | `drbd_ips` | `10.0.0.20`, `10.0.0.21` ||
| DRBD cluster vip | `drbd_cluster_vip` | `10.0.1.22` ||
| Netweaver ips | `netweaver_ips` | `10.0.0.30`, `10.0.0.31`, `10.0.0.32`, `10.0.0.33` | Addresses for the ASCS, ERS, PAS and AAS. The sequence will continue if there are more AAS machines |
| Netweaver virtual ips | `netweaver_virtual_ips` | `10.0.1.34`, `10.0.1.35`, `10.0.1.36`, `10.0.1.37` | The 1st virtual address will be the next in the sequence of the regular Netweaver addresses |

## Libvirt


Example based on `192.168.135.0/24` address range:

| Name | Substituted variable | Addresses | Comments |
| :---: | :---: | :----: | :---: |
| Iscsi server | `iscsi_srv_ip` | `192.168.135.4` ||
| Monitoring | `monitoring_srv_ip` | `192.168.135.5` ||
| Hana ips | `hana_ips` | `192.168.135.10`, `192.168.135.11` ||
| Hana cluster vip | `hana_cluster_vip` | `192.168.135.12` | Only used if HA is enabled in HANA |
| Hana cluster vip secondary | `hana_cluster_vip_secondary` | `192.168.135.13` | Only used if the Active/Active setup is used |
| DRBD ips | `drbd_ips` | `192.168.135.20`, `192.168.135.21` ||
| DRBD cluster vip | `drbd_cluster_vip` | `192.168.135.22` ||
| Netweaver ips | `netweaver_ips` | `192.168.135.30`, `192.168.135.31`, `192.168.135.32`, `192.168.135.33` | Addresses for the ASCS, ERS, PAS and AAS. The sequence will continue if there are more AAS machines |
| Netweaver virtual ips | `netweaver_virtual_ips` | `192.168.135.34`, `192.168.135.35`, `192.168.135.36`, `192.168.135.37` | The 1st virtual address will be the next in the sequence of the regular Netweaver addresses |
