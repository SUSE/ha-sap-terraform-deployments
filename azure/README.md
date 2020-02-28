# Azure Public Cloud deployment with terraform and Salt

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
The key files must be named as you define them in the `terraform.tfvars` file

3) **[Adapt saltstack pillars](../pillar_examples/)**

4) **Configure Terraform Access to Azure**

Install the azure client

* [azure commandline](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-zypper?view=azure-cli-latest)

Setup Azure account:

* Login with  `az login`.

* Check that the account has subscriptions with `az account list`. It should show you an entry for the tenant, and at least an entry for a subscription.

Then set the default subscription with the command `az account set`, for example, we are using the **"SUSE R&D General"** subscription, so we define that as the default subscription with:

```
az account set --subscription "SUSE R&D General"
```
You should be able to deploy now.


To verify which subscription is the active one, use the command `az account show`.

If you use terraform azure in CI see [terraform azure ci](terraform-azure-ci)

5) **Deploy**

```
terraform init
terraform workspace new myexecution # optional
terraform workspace select myexecution # optional
terraform plan
terraform apply
```

Connect using `ssh` as the user set as your `admin_user` parameter, for example:

```
ssh admin_user@18.196.143.128 -i private_key_location
```

Destroy the created infrastructure with:

```
terraform destroy
```

# Highlevel description

The terraform configuration files in this directory can be used to create the infrastructure required to install a SAP HanaSR cluster on Suse Linux Enterprise Server for SAP Applications in **Azure**.

The infrastructure deployed includes:

* An azure resource group.
* A virtual network
* A local subnet within the virtual network.
* Network interface card resources for the virtual machines.
* Public IP access for the virtual machines.
* Network security group with rules for access to the instances created in the subnet. Only allowed external network traffic is for the protocols: SSH, HTTP, HTTPS, and for the HAWK service. Internally to the subnet, all traffic is allowed.
* Virtual machines to deploy.

By default, this configuration will create 3 virtual machines in Azure: one for support services (mainly iSCSI as most other services are provided by Azure), and 2 cluster nodes, but this can be changed to deploy more cluster nodes as needed.

Once the infrastructure is created by Terraform, the servers are provisioned with Salt.

## Provisioning by Salt
By default, the cluster and HANA installation is done using Salt Formulas in foreground.
To customize this provisioning, you have to create the pillar files (cluster.sls and hana.sls) according to the examples in the [pillar_examples](../pillar_examples) folder (more information in the dedicated [README](../pillar_examples/README.md))

## Specification

These are the relevant files and what each provides:

- [variables.tf](variables.tf): definition of variables used in the configuration. These include definition of the number and type of instances, Azure region, etc.

- [main.tf](main.tf): definition of the network resources, Azure resource group and storage account to use.

- [salt_provisioner.tf](salt_provisioner.tf): salt provisioning resources.

- [salt_provisioner_script.tpl](../salt/salt_provisioner_script.tpl): template code for the initialization script for the servers. This will add the salt-minion if needed and execute the SALT deployment.

- [outputs.tf](outputs.tf): definition of outputs of the terraform configuration.

- [terraform.tfvars.example](terraform.tfvars.example): file containing initialization values for variables used throughout the configuration. **Rename/Duplicate this file to terraform.tfvars and edit the content with your values before use**.

### Variables

**Important:** The image used for the iSCSI server **must be at least SLES 15 version** since the      iSCSI salt formula is not compatible with lower versions.
**Custom Images:** The custom images for the virtual machines are defined in each terraform module. The image resources will be only created if the specific uri such as sles4sap_uri, iscsi_srv_uri are set in the terraform.tfvars file. Otherwise, a public image will be used.

In the file [terraform.tfvars.example](terraform.tfvars.example) there are a number of variables that control what is deployed. Some of these variables are:

* **sles4sap_uri**: path to a custom sles4sap image to install in the cluster nodes.
* **iscsi_srv_uri**: path to a custom image to install the iscsi server.
* **sles4sap_public**: map with the required information to install a public sles4sap image in the cluster nodes. This data is only used if `sles4sap_uri` is not set.
* **iscsi_srv_public**: map with the required information to install a public sles4sap image in the support server. This data is only used if `iscsi_srv_uri` is not set.
* **admin_user**: name of the administration user to deploy in all virtual machines.
* **private_key_location**: path to the local file containing the private SSH key to configure in the virtual machines to allow access.
* **public_key_location**: path to the local file containing the public SSH key to configure in the virtual machines to allow access. This public key is configured in the file `$HOME/.ssh/authorized_keys` of the administration user in the remote virtual machines.
* **storage_account_name**: Azure storage account name.
* **storage_account_key**: Azure storage account secret key (key1 or key2).
* **hana_inst_master**: path to the storage account where SAP HANA installation files are stored.
* **hana_fstype**: filesystem type used for HANA installation (xfs by default).
* **hana_vm_size**: SKU to use for the cluster nodes; basically the "size" (number of vCPUS and memory) of the VM.
* **hana_data_disk_type**: disk type to use for HANA (Standard_LRS by default).
* **hana_data_disk_caching**: caching mode for HANA disk, could be None, ReadOnly or ReadWrite (ReadWrite by default).
* **hana_count**: number of cluster nodes to deploy. 2 by default.
* **hana_instance_number**: Instance number for SAP HANA. 00 by default.
* **az_region**: Azure region where to deploy the configuration.
* **init_type**: initialization script parameter that controls what is deployed in the cluster nodes. Valid values are `all` (installs Hana and configures cluster), `skip-hana` (does not install Hana, but configures cluster) and `skip-cluster` (installs hana, but does not configure cluster). Defaults to `all`.
* **iscsidev**: device used by the iSCSI server to provide LUNs.
* **iscsi_disks**: attached partitions number for iscsi server.
* **cluster_ssh_pub**: SSH public key name (must match with the key copied in sshkeys folder)
* **cluster_ssh_key**: SSH private key name (must match with the key copied in sshkeys folder)
* **ha_sap_deployment_repo**: Repository with HA and Salt formula packages. The latest RPM packages can be found at [https://download.opensuse.org/repositories/network:/ha-clustering:/Factory/{YOUR OS VERSION}](https://download.opensuse.org/repositories/network:/ha-clustering:/Factory/)
* **scenario_type**: SAP HANA scenario type. Available options: `performance-optimized` and `cost-optimized`.
* **provisioner**: select the desired provisioner to configure the nodes. Salt is used by default: [salt](../salt). Let it empty to disable the provisioning part.
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

 * **additional_packages**: Additional packages to add to the guest machines.
 * **hosts_ips**: Each cluster nodes IP address (sequential order). Mandatory to have a generic `/etc/hosts` file.

[Specific QA variables](../doc/qa.md#specific-qa-variables)

### The pillar files hana.sls and cluster.sls

Find more information about the hana and cluster formulas in (check the pillar.example files):

-   [https://github.com/SUSE/saphanabootstrap-formula](https://github.com/SUSE/saphanabootstrap-formula)
-   [https://github.com/SUSE/habootstrap-formula](https://github.com/SUSE/habootstrap-formula)

As a good example, you could find some pillar examples into the folder [pillar_examples](../pillar_examples)
These files **aren't ready for deployment**, be careful to customize them or create your own files.

# Advanced usage

## Terraform Azure CI

To setup the authentification for CI purposes you will need 4 variables:

* Subscription ID
* Tenant ID
* Client or App ID
* Client or App Secret

The subscription and tenant id can be seen with the command `az account show`:

```
$ az account show
{
  "environmentName": "AzureCloud",
  "id": "<HERE IS THE SUBSCRIPTION ID>",
  "isDefault": true,
  "name": "<HERE IS THE SUBSCRIPTION NAME>",
  "state": "Enabled",
  "tenantId": "<HERE IS THE TENANT ID>",
  "user": {
    "name": "some@email.address.com",
    "type": "user"
  }
}
```

For the client id and secret, an Azure AD Service Principal is required. If you have the necessary permissions, you can create one with:

```
az ad sp create-for-rbac --name my-terraform-ad-sp --role="Contributor" --scopes="/subscriptions/<HERE GOES THE SUBSCRIPTION ID>"
```

This command should output the necesary client id and client secret or password.

More info in the [Terraform Install Configure document](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure) in microsoft.com.

Once all four required parameters are known, there are several ways to configure access for terraform:

* In provider definition

Add the values for subscription id, tenant id, client id and client secret in the file [main.tf](main.tf).

* Via Environment Variables

Set the following environment variables before running terraform:
To verify which subscription is the active one, use the command `az account show`.

```
export ARM_SUBSCRIPTION_ID=your_subscription_id
export ARM_CLIENT_ID=your_appId
export ARM_CLIENT_SECRET=your_password
export ARM_TENANT_ID=your_tenant_id
export ARM_ACCESS_KEY=access_key
```

## How to upload a custom image

In the terraform configuration we are using a custom images which are defined in the main.tf files of terraform modules (under the `storage_image_reference` block) and referenced as `azurerm_image.iscsi_srv.*.id` and `azurerm_image.sles4sap.*.id`.

This custom images need to be already uploaded to Azure before attempting to use it with terraform, as terraform does not have a mechanism to upload images as of yet.

In order to upload images for further use in terraform, use the procedure defined in the [Upload a custom image](#upload-custom-image) section below. Be sure to set up your Azure account first with the azure-cli to be able to follow that procedure.

On the other hand, if there is a need to use publicly available images, the `terraform.tfvars` file must include the required information as in the following example (by default, the example values will be used if new information is not provided in the `terraform.tfvars` file):

```
# Public sles4sap image
sles4sap_public = {
  "publisher" = "SUSE"
  "offer"     = "SLES-SAP-BYOS"
  "sku"       = "12-sp4"
  "version"   = "2019.03.06"
}

# Public iscsi server image
iscsi_srv_public = {
  "publisher" = "SUSE"
  "offer"     = "SLES-SAP-BYOS"
  "sku"       = "15"
  "version"   = "2018.08.20"
}
```

To check the values for publisher, offer, sku and version of the available public images, use the command `az vm image list --output table`. For example, to check for the public images from SUSE available in Azure:

```
az vm image list --output table --publisher SUSE --all
```

If using a public image, skip to the [how to use section](#how-to-use).


### Upload custom image

In order to upload a custom image, we require a valid resource group, with a storage account and a storage container.

To list the resource groups available to your account, run the command `az group list`. If there is a need to create a new resource group, run:

```
az group create --location westeurope --name MyResourceGroup
```

This will create a resource group called **MyResourceGroup**. To verify the details of the resource group, run:

```
az group show --name MyResourceGroup
```

Once you have a resource group, the next step is to create an storage account, do that with:

```
az storage account create --resource-group MyResourceGroup --location westeurope --name MyStorageAccount --kind Storage --sku Standard_LRS
```

This creates the **MyStorageAccount** storage account in the **MyResourceGroup** resource group. Verify that it was created with either of these commands:

```
az storage account list | grep MyStorageAccount
az storage account show --name MyStorageAccount
```

Once you have the storage account, you will need the keys stored in it. You can get that information with the command:

```
az storage account keys list --resource-group MyResourceGroup --account-name MyStorageAccount
```

The output to that command will look like this:

```
[
  {
    "keyName": "key1",
    "permissions": "Full",
    "value": "key_1_value"
  },
  {
    "keyName": "key2",
    "permissions": "Full",
    "value": "key_2_value"
  }
]
```

Either one of these keys is required for the next steps, so keep it on hand. First, to create a storage container:

```
az storage container create --account-name MyStorageAccount --account-key "key_1_value" --name MyStorageContainer
```

This creates a **MyStorageContainer** in the **MyStorageAccount** storage account, using key 1.

Verify that it was created with either of these commands:

```
az storage container list --account-name MyStorageAccount
az storage container show --account-name MyStorageAccount --name MyStorageContainer
```

Once you have set up the storage account and the storage container, the next step is to upload the image. Ensure that the image file to upload is not compressed, and then upload it with the command:

```
az storage blob upload --account-name MyStorageAccount --account-key "key_1_value" --container-name MyStorageContainer --type page --file SLES12-SP4-SAP-Azure-BYOS.x86_64-0.9.0-Build2.1.vhdfixed --name SLES12-SP4-SAP-Azure-BYOS.x86_64-0.9.0-Build2.1.vhd
```

This will upload the image file `SLES12-SP4-SAP-Azure-BYOS.x86_64-0.9.0-Build2.1.vhdfixed` as the blob `SLES12-SP4-SAP-Azure-BYOS.x86_64-0.9.0-Build2.1.vhd`. This process takes a while to complete, depending on the network speed to Azure, and the size of the image.

Verify the image was uploaded with either of the following commands:

```
az storage blob list --account-name MyStorageAccount --container-name MyStorageContainer
az storage blob show --name SLES12-SP4-SAP-Azure-BYOS.x86_64-0.9.0-Build2.1.vhd --container-name MyStorageContainer --account-name MyStorageAccount
az storage blob exists --name SLES12-SP4-SAP-Azure-BYOS.x86_64-0.9.0-Build2.1.vhd --container-name MyStorageContainer --account-name MyStorageAccount
```

Once the image is successfully uploaded, get its URL/URI with the command:

```
az storage blob url --name SLES12-SP4-SAP-Azure-BYOS.x86_64-0.9.0-Build2.1.vhd --container-name MyStorageContainer --account-name MyStorageAccount
```

This URI will be used in the terraform configuration, specifically in the main.tf file of corresponding terraform module or via the command line, so keep it on hand.

### Remove resources

To remove resources, substitute show for delete in all check commands. For example:

```
az storage blob delete --name SLES12-SP4-SAP-Azure-BYOS.x86_64-0.9.0-Build2.1.vhd --container-name MyStorageContainer --account-name MyStorageAccount
```

Will delete blob `SLES12-SP4-SAP-Azure-BYOS.x86_64-0.9.0-Build2.1.vhd` from storage container `MyStorageContainer`.

## Extra info
More info in [Azure's Terraform Create Complete VM Document](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-create-complete-vm).
