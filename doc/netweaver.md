# Netweaver

Besides the default SAP Hana and HA cluster environment, the project can be tuned to deploy a SAP Netweaver environment too. This allows to have a Netweaver landscape working with the SAP Hana database (**by now, the project only works with SAP Hana as database**). The next SAP Netweaver components are available:
- ASCS instance
- ERS instance
- PAS instance
- AAS instance
- Database instance (this adds the required users, tables, views, etc to the current Hana database)

The deployment will create 4 new virtual machines to host the Netweaver environment and a new shared disk used by the ASCS and ERS instances.

Besides the standard installation, an additional HA cluster might be added in top of the ASCS and ERS communication to assure high availability between these two components using the *sap_suse_cluster_connector* (HA is enabled by default).

More details in the official [Suse documentation](https://www.suse.com/media/white-paper/sap_netweaver_availability_cluster_740_setup_guide.pdf?_ga=2.211949268.1511104453.1571203291-1421744106.1546416539).

The deployment is performed using the [sapnwbootstrap-formula](https://github.com/SUSE/sapnwbootstrap-formula).

Available for libvirt, azure, gcp and aws.

## Quickstart

In order to deploy a SAP Netweaver environment with SAP Hana some changes must be executed in terraform and salt folders. **By default SAP Netweaver is not enabled.**

- In order to enable/disable the Netweaver deployment update the value of `netweaver_enabled` variable to true/false in the `terraform.tfvars` file.

- Set the `netweaver_ha_enabled` option to create a ASCS, ERS, PAS and AAS environment. Setting this value to false will only create a ASCS and PAS without any HA functionality

- In order to deploy a correct Netweaver environment a NFS share is needed (SAP stores some shared files there). The NFS share must have the folders `sapmnt` and `usrsapsys` in the exposed folder. It's a good practice to store this folder with the Netweaver SID name (for example `/sapdata/HA1/sapmnt` and `/sapdata/HA1/usrsapsys`). **This subfolders content is removed by default during the deployment**. This NFS share can be created using the provided `drbd` module deployment that fully automatize this (`drbd` deployment is required for **azure and gcp**, **aws** uses the EFS storage by default).

- **For libvirt**: Add the `netweaver_inst_media` variable to the `terraform.tfvars` with the address to the NFS share containing the netweaver installation software (`swpm`) folder, `sapexe` folder, `Netweaver Export` folder and `HANA HDB Client` folders (`Netweaver Export` and `HANA HDB Client` are required if the Database, PAS and AAS instances need to be installed). The `netweaver.sls` pillar file must also be updated with all this information. `Netweaver Export` and `HANA HDB Client` folders must be provided in `additional_dvds` list.

- **For azure**: Add the azure storage account variables to the `terraform.tfvars` with the , `sapexe` folder, `Netweaver Export` folder and `HANA HDB Client` folders (`Netweaver Export` and `HANA HDB Client` are required if the Database, PAS and AAS instances need to be installed). The `netweaver.sls` pillar file must also be updated with all this information. `Netweaver Export` and `HANA HDB Client` folders must be provided in `additional_dvds` list.

- **For aws**: Add the aws S3 bucket variable (`netweaver_s3_bucket`) to the `terraform.tfvars` with the , `sapexe` folder, `Netweaver Export` folder and `HANA HDB Client` folders (`Netweaver Export` and `HANA HDB Client` are required if the Database, PAS and AAS instances need to be installed). The `netweaver.sls` pillar file must also be updated with all this information. `Netweaver Export` and `HANA HDB Client` folders must be provided in `additional_dvds` list. Note: Netweaver will use the Amazon Elastic File System(EFS) for its NFS share by default, unless drbd option is enabled (using `drbd_enabled` variable).


- **For gcp**: Add the gcp storage bucket variable to the `terraform.tfvars` with the , `sapexe` folder, `Netweaver Export` folder and `HANA HDB Client` folders (`Netweaver Export` and `HANA HDB Client` are required if the Database, PAS and AAS instances need to be installed). The `netweaver.sls` pillar file must also be updated with all this information. `Netweaver Export` and `HANA HDB Client` folders must be provided in `additional_dvds` list.

- Add new additional IP addresses to the variable `nw_ips` and `nw_virtual_ips` in the `terraform.tfvars`. This variable is a list containing the IP addresses of the new virtual machines hosting the Netweaver components, so if 4 virtual machines are used (default option) 4 addresses must be added there in the same range than the machines hosting the Hana database.

- Add the `netweaver_nfs_share` variable to the `terraform.tfvars` with the address to the NFS share containing the `sapmnt` and `usrsapsys` folders. Following the current example this would be `nfs_address:/sapdata/HA1`.

- Modify the content of [cluster.sls](../pillar/netweaver/cluster.sls) and [netweaver.sls](../pillar/netweaver/netweaver.sls). The unique mandatory changes are `swpm_folder`, `sapexe_folder` and `additional_dvds` in the `netweaver.sls` file. These values must match with the folder of your `sap_inst_media`, the current values are just an example.

- If the [netweaver.sls](pillar_examples/automatic/netweaver/netweaver.sls) pillar file from `pillar_examples/automatic/netweaver` is used, the parameters `netweaver_swpm_folder`, `netweaver_sapexe_folder` and `netweaver_additional_dvds` must be set in the `tfvars` file with the same data explained in the previous points.
