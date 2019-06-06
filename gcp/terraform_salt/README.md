# Google Cloud Platform deployment with Terraform

This Terraform configuration deploys SAP HANA in a High-Availability Cluster on SUSE Linux Enterprise Server for SAP Applications in the **Google Cloud Platform**.

The infrastructure deployed includes:

- A virtual network with a local subnetwork.
- Rules for access to the instances created.
- Public IP access for the virtual machines via ssh.
- The definition of the image to use in the virtual machines.
- Virtual machines to deploy.

By default, this configuration will create 3 instances in GCP: one for support services (mainly iSCSI as most other services - DHCP, NTP, etc - are provided by Google) and 2 cluster nodes, but this can be changed to deploy more cluster nodes as needed.

Once the infrastructure created by Terraform, the servers are provisioned with Salt in background.

## Provisioning by Salt
The cluster and HANA installation is done using Salt Formulas.
To customize this provisioning, you have to create the pillar files (cluster.sls and hana.sls) according to the examples in the [pillar_examples](https://github.com/SUSE/ha-sap-terraform-deployments/blob/master/pillar_examples) folder (more information in the dedicated [README](https://github.com/SUSE/ha-sap-terraform-deployments/blob/master/pillar_examples/README.md))

## Prerequisites

1. First, a GCP account with an active subscription is required.

2. Install the GCloud SDK following the [documentation](https://cloud.google.com/sdk/docs/quickstart-linux)

3. In the [web console](https://console.cloud.google.com/iam-admin/serviceaccounts) create a new personal key for the service account of your project and download the JSON file.

4. Log in with `gcloud init`.

Note: You must run this command to use the Gcloud SDK and to apply this Terraform configuration:

`export GOOGLE_APPLICATION_CREDENTIALS=/path/to/<PROJECT-ID>-xxxxxxxxx.json`

5. A Google Storage bucket must be created with the files containing the HANA installer.

The bucket may be created and populated with these commands:

This is an example where **51053381** is the targeted HANA version to upload.
```
gsutil mb gs://sap_instmasters/51053381/
gsutil cp 51053381/ gs://sap_instmasters/51053381/
```

Bucket names have more restrictions than object names and must be globally unique, because every bucket resides in a single Cloud Storage namespace. Also, bucket names can be used with a CNAME redirect, which means they need to conform to DNS naming conventions. For more information, see the [bucket naming guidelines](https://cloud.google.com/storage/docs/naming#requirements).

6. A bucket for the images must be created to hold the custom SLES images to use.

```
gsutil mb gs://sles-images
```

7. Upload the image you want to use with:

`gsutil cp OS-Image-File-for-SLES4SAP-for-GCP.tar.gz gs://sles-images`

## Relevant files

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

## How to use

1. Rename [terraform.tfvars.example](terraform.tfvars.example) to *terraform.tfvars* and edit to suit your needs or use `terraform [-var VARIABLE=VALUE]...` to override defaults.

 Then, from your working directory, generate private and public keys for the cluster nodes with the following commands:
```
 mkdir provision/hana_node/files/sshkeys; ssh-keygen -t rsa -f provision/hana_node/files/sshkeys/cluster.id_rsa
 ```
 The key files need to be named as you defined it in `terraform.tfvars` file.

In the file [terraform.tfvars](terraform.tfvars.example) there are a number of variables that control what is deployed. Some of these variables are:

* **project**: must contain the project name.
* **gcp_credentials_file**: must contain the path to the JSON file with the GCP credentials created above.
* **ip_cidr_range**: must contain the internal IPv4 range.
* **iscsi_ip**:  must contain the iscsi server IP.
* **machine_type** and **machine_type_iscsi_server** variables must contain the [GCP machine type](https://cloud.google.com/compute/docs/machine-types) for the SAP HANA nodes as well as the iSCSI server node.
* **private_key_location**: the path to your SSH private key.  This is used by the provisioner.
* **public_key_location**: the path to your SSH public key.  This is used to access the instances.
* **region**: the name of the desired region.
* **sap_hana_deployment_bucket**: the name of the Google Storage bucket with the HANA installation files.
* **images_path_bucket**: the name of the Google Storage bucket with the SLES image.
* **sles4sap_os_image_file**: the name of the SLES4SAP image.

**Important:** The image used for the iSCSI server **must be at least SLES 15 version** since the iSCSI salt formula is not compatible with lower versions. Use the variable `sles_os_image_file` below.
* **sles_os_image_file**: the name of the SLES image for the iSCSI server used for SBD stonith.
* **init_type**: variable controls what is deployed in the cluster nodes. Valid values are `all` (installs HANA and configures cluster), `skip-hana` (does not install HANA, but configures cluster). Defaults to `all`.
* **iscsidev**: device used by the iSCSI server to provide LUNs.
* **cluster_ssh_pub**: path to a custom ssh public key to upload to the nodes.
* **cluster_ssh_key**: path to a custom ssh private key to upload to the nodes.
* **host_ips**: each cluster nodes IP address (sequential order). Mandatory to have a generic `/etc/hosts` file.
* **hana_inst_folder**: path where HANA installation master will be downloaded from `GCP Bucket`.
* **hana_inst_disk_device**: device used by node where HANA will be downloaded.
* **hana_disk_device**: device used by node where HANA will be installed.
* **ha_sap_deployment_repo**: Repository with HA and Salt formula packages. The latest RPM packages can be found at [https://download.opensuse.org/repositories/network:/ha-clustering:/Factory/{YOUR OS VERSION}](https://download.opensuse.org/repositories/network:/ha-clustering:/Factory/)
* **scenario_type**: SAP HANA scenario type. Available options: `performance-optimized` and `cost-optimized`.
* **provisioner**: select the desired provisioner to configure the nodes. Salt is used by default: [salt](../../salt). Let it empty to disable the provisioning part.
* **background**: run the provisioning process in background finishing terraform execution.
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

 Specific QA variable
* **qa_mode**: If set to true, it disables extra packages not already present in the image. For example, set this value to true if performing the validation of a new AWS Public Cloud image.

### The pillar files hana.sls and cluster.sls

 Find more information about the hana and cluster formulas in (check the pillar.example files):

 -   [https://github.com/SUSE/saphanabootstrap-formula](https://github.com/SUSE/saphanabootstrap-formula)
 -   [https://github.com/SUSE/habootstrap-formula](https://github.com/SUSE/habootstrap-formula)

 As a good example, you could find some pillar examples into the folder [pillar_examples](https://github.com/SUSE/ha-sap-terraform-deployments/blob/master/pillar_examples)
 These files **aren't ready for deployment**, be careful to customize them or create your own files.

### QA usage
 You may have noticed the variable *qa_mode*, this project is also used for QA testing.

 **qa_mode** is used to inform the deployment that we are doing QA, for example disable extra packages installation (sap, ha pattern etc). In this case, don't forget to set qa_mode to true.

2. Deploy:

```
terraform init
terraform plan -var "name=testing"
terraform apply -var "name=testing"
```

3. Destroy:

When you are done, run:

`terraform destroy -var "name=testing"`

## Notes

- This configuration supports [Terraform workspaces](https://www.terraform.io/docs/state/workspaces.html).
