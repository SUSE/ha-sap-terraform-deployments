# Google Cloud Platform deployment with Terraform

 - [quickstart](#quickstart)
 - [highlevel description](#highlevel-description)
 - [advanced usage](#advanced-usage)
 - [monitoring](../doc/monitoring.md)
 - [QA](../doc/qa.md)
 - [specification](#specification)

# Quickstart

1) **Rename terraform.tfvars:** `mv terraform.tfvars.example terraform.tfvars`

2) **Generate private and public keys for the cluster nodes with:**

```
mkdir ../salt/hana_node/files/sshkeys
ssh-keygen -t rsa -f ../salt/hana_node/files/sshkeys/cluster.id_rsa
```

The key files need to have same name as defined in [terraform.tfvars](terraform.tfvars.example)

3) **[Adapt saltstack pillars](../pillar_examples/)**

4) **Configure Terraform access to GCP**

- First, a GCP account with an active subscription is required.

- Install the GCloud SDK following the [documentation](https://cloud.google.com/sdk/docs/quickstart-linux)

- Create a new personal key for the service account of your google cloud project with https://console.cloud.google.com/apis/credentials/serviceaccountkey?_ga=2.91196186.-1602867212.1565799790.
   See also https://cloud.google.com/community/tutorials/getting-started-on-gcp-with-terraform

- Log in with `gcloud init`.

Note: You must run this command to use the Gcloud SDK and to apply this Terraform configuration:

`export GOOGLE_APPLICATION_CREDENTIALS=/path/to/<PROJECT-ID>-xxxxxxxxx.json`

5) **Deploy**:

```
terraform init
terraform workspace new my-execution # optional
terraform workspace select my-execution # optional
terraform plan
terraform apply
```

Destroy the created infrastructure with:

```
terraform destroy
```

# Highlevel description

This Terraform configuration deploys SAP HANA in a High-Availability Cluster on SUSE Linux Enterprise Server for SAP Applications in the **Google Cloud Platform**.

The infrastructure deployed includes:

- A virtual network with a local subnetwork.
- Rules for access to the instances created.
- Public IP access for the virtual machines via ssh.
- The definition of the image to use in the virtual machines.
- Virtual machines to deploy.

By default, this configuration will create 3 instances in GCP: one for support services (mainly iSCSI as most other services - DHCP, NTP, etc - are provided by Google) and 2 cluster nodes, but this can be changed to deploy more cluster nodes as needed.

## Provisioning by Salt
By default, the cluster and HANA installation is done using Salt Formulas in foreground.
To customize this provisioning, you have to create the pillar files (cluster.sls and hana.sls) according to the examples in the [pillar_examples](https://github.com/SUSE/ha-sap-terraform-deployments/blob/master/pillar_examples) folder (more information in the dedicated [README](https://github.com/SUSE/ha-sap-terraform-deployments/blob/master/pillar_examples/README.md))

## Specification

These are the relevant files and what each provides:

- [disks.tf](disks.tf): definitions of the storage used for images and virtual machines.

- [instances.tf](instances.tf): definition of the GCP instances to create on deployment.

- [network.tf](network.tf): definition of network resources used by the infrastructure and the firewall rules.

- [outputs.tf](outputs.tf): definition of outputs of the terraform configuration.

- [provider.tf](provider.tf): definition of the providers being used in the terraform configuration.

- [remote-state.sample](remote-state.sample): sample file for the definition of the backend to [store the Terraform state file remotely](create_remote_state).

- [salt_provisioner.tf](salt_provisioner.tf): salt provisioning resources.

- [salt_provisioner_script.tpl](../../salt/salt_provisioner_script.tpl): template code for the initialization script for the servers. This will add the salt-minion if needed and execute the SALT deployment.

- [variables.tf](variables.tf): definition of variables used in the configuration.

- [terraform.tfvars.example](terraform.tfvars.example): file containing initialization values for variables used throughout the configuration. **Rename/Duplicate this file to terraform.tfvars and edit the content with your values before use**.

#### Variables

In the file [terraform.tfvars](terraform.tfvars.example) there are a number of variables that control what is deployed. Some of these variables are:

* **project**: must contain the project name.
* **gcp_credentials_file**: must contain the path to the JSON file with the GCP credentials created above.
* **ip_cidr_range**: must contain the internal IPv4 range.
* **iscsi_ip**:  must contain the iscsi server IP.
* **machine_type** and **machine_type_iscsi_server** variables must contain the [GCP machine type](https://cloud.google.com/compute/docs/machine-types) for the SAP HANA nodes as well as the iSCSI server node.
* **hana_data_disk_type**: disk type to use for HANA data (pd-ssd by default).
* **hana_data_disk_size**: disk size on GB to use for HANA data disk (834GB by default).
* **hana_backup_disk_type**: disk type to use for HANA data backup (pd-standard by default).
* **hana_backup_disk_size**: disk size on GB to use for HANA backup disk (416GB by default).
* **private_key_location**: the path to your SSH private key.  This is used by the provisioner.
* **public_key_location**: the path to your SSH public key.  This is used to access the instances.
* **region**: the name of the desired region.
* **sap_hana_deployment_bucket**: the name of the Google Storage bucket with the HANA installation files.
* **hana_platform_folder**: path relative to sap_hana_deployment_bucket, where already extracted HANA platform installation media exists. This media will have preference over hdbserver sar archive installation media.
* **hana_sapcar_exe**: the path to the sapcar executable, relative to sap_hana_deployment_bucket.
* **hdbserver_sar**: the path to the HANA database server installation sar archive, relative to sap_hana_deployment_bucket.
* **hana_extract_dir**: The sar archive will be extracted to path specified at hdbserver_extract_dir. This parameter is optional (by default /sapmedia/HANA).
* **sles4sap_boot_image**: the name of the SLES4SAP image.

**Important:** The image used for the iSCSI server **must be at least SLES 15 version** since the iSCSI salt formula is not compatible with lower versions. Use the variable `iscsi_server_boot_image` below.
* **iscsi_server_boot_image**: the name of the SLES image for the iSCSI server used for SBD stonith.
* **init_type**: variable controls what is deployed in the cluster nodes. Valid values are `all` (installs HANA and configures cluster), `skip-hana` (does not install HANA, but configures cluster). Defaults to `all`.
* **iscsidev**: device used by the iSCSI server to provide LUNs.
* **iscsi_disks**: attached partitions number for iscsi server.
* **cluster_ssh_pub**: path to a custom ssh public key to upload to the nodes.
* **cluster_ssh_key**: path to a custom ssh private key to upload to the nodes.
* **hana_inst_folder**: path where HANA installation master will be downloaded from `GCP Bucket`.
* **hana_disk_device**: device used by node where HANA will be installed (/dev/sdb by default).
* **hana_backup_device**: device used by node where HANA backup will be stored (/dev/sdc by default).
* **hana_inst_disk_device**: device used by node where HANA will be downloaded (/dev/sdd by default).
* **hana_cluster_vip**: IP address used to configure the hana cluster floating IP. It must be in other subnet than the machines!
* **ha_sap_deployment_repo**: Repository with HA and Salt formula packages. The latest RPM packages can be found at [https://download.opensuse.org/repositories/network:/ha-clustering:/Factory/{YOUR OS VERSION}](https://download.opensuse.org/repositories/network:/ha-clustering:/Factory/)
* **scenario_type**: SAP HANA scenario type. Available options: `performance-optimized` and `cost-optimized`.
* **provisioner**: select the desired provisioner to configure the nodes. Salt is used by default: [salt](../../salt). Let it empty to disable the provisioning part.
* **background**: run the provisioning process in background finishing terraform execution.
* **pre_deployment**: Enable pre deployment local execution steps. E.g. Move pillar files from pillar_examples/automatic, create cluster ssh keys, etc (disabled by default).
* **reg_code**: registration code for the installed base product (Ex.: SLES for SAP). This parameter is optional. If informed, the system will be registered against the SUSE Customer Center.
* **reg_email**: email to be associated with the system registration. This parameter is optional.
* **reg_additional_modules**: additional optional modules and extensions to be registered (Ex.: Containers Module, HA module, Live Patching, etc). The variable is a key-value map, where the key is   the _module name_ and the value is the _registration code_. If the _registration code_ is not needed,  set an empty string as value. The module format must follow SUSEConnect convention:
    - `<module_name>/<product_version>/<architecture>`
    - *Example:* Suggested modules for SLES for SAP 15

          sle-module-basesystem/15/x86_64
          sle-module-desktop-applications/15/x86_64
          sle-module-server-applications/15/x86_64
          sle-ha/15/x86_64 (use the same regcode as SLES for SAP)
          sle-module-sap-applications/15/x86_64

 For more information about registration, check the ["Registering SUSE Linux Enterprise and Managing Modules/Extensions"](https://www.suse.com/documentation/sles-15/book_sle_deployment/data/cha_register_sle.html) guide.

 * **additional_packages**: Additional packages to add to the guest machines.
 * **hosts_ips**: Each cluster nodes IP address (sequential order). Mandatory to have a generic `/etc/hosts` file.

[Specific QA variables](https://github.com/juadk/ha-sap-terraform-deployments/blob/improve_QA_documentation/doc/qa.md#specific-qa-variables)

# Advanced Usage

A Google Storage bucket must be created with the files containing the HANA installer.

The bucket may be created and populated with these commands:

This is an example where **51053381** is the targeted HANA version to upload.
```
gsutil mb gs://sap_instmasters/51053381/
gsutil cp 51053381/ gs://sap_instmasters/51053381/
```

Bucket names have more restrictions than object names and must be globally unique, because every bucket resides in a single Cloud Storage namespace. Also, bucket names can be used with a CNAME redirect, which means they need to conform to DNS naming conventions. For more information, see the [bucket naming guidelines](https://cloud.google.com/storage/docs/naming#requirements).

 A bucket for the images must be created to hold the custom SLES images to use.
```
gsutil mb gs://sles-images
```

Upload the image you want to use with:
```
gsutil cp OS-Image-File-for-SLES4SAP-for-GCP.tar.gz gs://sles-images/OS-Image-File-for-SLES4SAP-for-GCP.tar.gz
```

Create a bootable image
```
gcloud compute images create OS-Image-File-for-SLES4SAP-for-GCP --source-uri gs://sles-images/OS-Image-File-for-SLES4SAP-for-GCP.tar.gz
```
