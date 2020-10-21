# Azure Public Cloud deployment with terraform and Salt

- [quickstart](#quickstart)
- [highlevel description](#highlevel-description)
- [advanced usage](#advanced-usage)
- [monitoring](../doc/monitoring.md)
- [QA](../doc/qa.md)
- [specification](#specification)

# Quickstart

1) **Rename terraform.tfvars:** `mv terraform.tfvars.example terraform.tfvars`

Now, the created file must be configured to define the deployment.

**Note:** Find some help in the IP addresses configuration in [IP auto generation](../doc/ip_autogeneration.md#Azure)

2) **Generate private and public keys for the cluster nodes without specifying the passphrase:**

Alternatively, you can set the `pre_deployment` variable to automatically create the cluster ssh keys.
```
mkdir -p ../salt/sshkeys
ssh-keygen -f ../salt/sshkeys/cluster.id_rsa -q -P ""
```
The key files must be named as you define them in the `terraform.tfvars` file

3) **[Adapt saltstack pillars manually](../pillar_examples/)** or set the `pre_deployment` variable to automatically copy the example pillar files.

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

### Bastion

By default, the bastion machine is enabled in Azure (it can be disabled), which will have the unique public IP address of the deployed resource group. Connect using ssh and the selected admin user with: ```ssh {admin_user}@{bastion_ip} -i {private_key_location}```

To log to hana and others instances, use:
```
ssh -o ProxyCommand="ssh -W %h:%p {admin_user}@{bastion_ip} -i {private_key_location} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" {admin_user}@{private_hana_instance_ip} -i {private_key_location} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
```

To disable the bastion use:

```bastion_enabled = false```

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

# Specifications

In order to deploy the environment, different configurations are available through the terraform variables. These variables can be configured using a `terraform.tfvars` file. An example is available in [terraform.tfvars.example](./terraform.tvars.example). To find all the available variables check the [variables.tf](./variables.tf) file.

## QA deployment

The project has been created in order to provide the option to run the deployment in a `Test` or `QA` mode. This mode only enables the packages coming properly from SLE channels, so no other packages will be used. Find more information [here](../doc/qa.md).

## Pillar files configuration

Besides the `terraform.tfvars` file usage to configure the deployment, a more advanced configuration is available through pillar files customization. Find more information [here](../pillar_examples/README.md).

## Use already existing network resources

The usage of already existing network resources (virtual network and subnets) can be done configuring
the `terraform.tfvars` file and adjusting some variables. The example of how to use them is available
at [terraform.tfvars.example](terraform.tfvars.example).

## Autogenerated network addresses

The assignment of the addresses of the nodes in the network can be automatically done in order to avoid
this configuration. For that, basically, remove or comment all the variables related to the ip addresses (more information in [variables.tf](variables.tf)). With this approach all the addresses will be retrieved based in the provided virtual network addresses range (`vnet_address_range`).

Autogenerated addresses example based in 10.74.0.0/24

Iscsi server: 10.74.0.4
Monitoring: 10.74.0.5
Hana ips: 10.74.0.10, 10.74.0.11
Hana cluster vip: 10.74.0.12
DRBD ips: 10.74.0.20, 10.74.0.21
DRBD cluster vip: 10.74.0.22
Netweaver ips: 10.74.0.30, 10.74.0.31, 10.74.0.32, 10.74.0.33
Netweaver virtual ips: 10.74.0.34, 10.74.0.35, 10.74.0.36, 10.74.0.37

## HANA configuration

The database configuration may vary depending on the expected performance. In order to have different options, the virtual machine size, disks, network configuration, etc must be configured differently. Here some predefined options that might help in the configuration.

For example, the disks configuration for the HANA database is a crucial step in order to deploy a functional database. The configuration creates multiple logical volumes to get the best performance of the database. Here listed some of the configurations that can be deployed to have difference experiences. Update your `terraform.tfvars` with these values. By default the **demo** option is deployed.
**Use other values only if you know what you are doing**.

#### Demo

```
hana_vm_size = "Standard_E4s_v3"
hana_enable_accelerated_networking = false
hana_data_disks_configuration = {
  disks_type       = "Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS"
  disks_size       = "128,128,128,128,128,128,128"
  caching          = "None,None,None,None,None,None,None"
  writeaccelerator = "false,false,false,false,false,false,false"
  luns             = "0,1#2,3#4#5#6#7"
  names            = "data#log#shared#usrsap#backup"
  lv_sizes         = "100#100#100#100#100"
  paths            = "/hana/data#/hana/log#/hana/shared#/usr/sap#/hana/backup"
}
```

#### Small

```
hana_vm_size = "Standard_E64s_v3"
hana_enable_accelerated_networking = true
hana_data_disks_configuration = {
  disks_type       = "Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS"
  disks_size       = "512,512,512,512,64,1024"
  caching          = "ReadOnly,ReadOnly,ReadOnly,ReadOnly,ReadOnly,None"
  writeaccelerator = "false,false,false,false,false,false"
  luns             = "0,1,2#3#4#5"
  names            = "datalog#shared#usrsap#backup"
  lv_sizes         = "70,100#100#100#100"
  paths            = "/hana/data,/hana/log#/hana/shared#/usr/sap#/hana/backup"
}
```

#### Medium

```
hana_vm_size = "Standard_M64s"
hana_enable_accelerated_networking = true
hana_data_disks_configuration = {
  disks_type       = "Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS"
  disks_size       = "512,512,512,512,512,512,1024,64,1024,1024"
  caching          = "ReadOnly,ReadOnly,ReadOnly,ReadOnly,None,None,ReadOnly,ReadOnly,ReadOnly,ReadOnly"
  writeaccelerator = "false,false,false,false,false,false,false,false,false,false"
  luns             = "0,1,2,3#4,5#6#7#8,9"
  names            = "data#log#shared#usrsap#backup"
  lv_sizes         = "100#100#100#100#100"
  paths            = "/hana/data#/hana/log#/hana/shared#/usr/sap#/hana/backup"
}
```

#### Large

```
hana_vm_size = "Standard_M128s"
hana_enable_accelerated_networking = true
hana_data_disks_configuration = {
  disks_type       = "Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS,Premium_LRS"
  disks_size       = "1024,1024,1024,512,512,1024,64,2048,2048"
  caching          = "ReadOnly,ReadOnly,ReadOnly,None,None,ReadOnly,ReadOnly,ReadOnly,ReadOnly"
  writeaccelerator = "false,false,false,true,true,false,false,false,false"
  luns             = "0,1,2#3,4#5#6#7,8"
  names            = "data#log#shared#usrsap#backup"
  lv_sizes         = "100#100#100#100#100"
  paths            = "/hana/data#/hana/log#/hana/shared#/usr/sap#/hana/backup"
}
```

## Netweaver configuration

There are different Netweaver configurations available depending on if the environment is an HA one or not, and the expected performance. Here some guidelines for the different options:

To set a 3-tier deployment (simple Netweaver, without HA) use the next options:

```
netweaver_enabled = true
netweaver_ha_enabled = false
netweaver_cluster_sbd_enabled = false
drbd_enabled = false
netweaver_nfs_share = your_nfs_share:/mount_point
```

For 3-tier HA deployment:

```
netweaver_enabled = true
netweaver_ha_enabled = true
netweaver_cluster_sbd_enabled = true
drbd_enabled = true
```

Besides that, we need to define the expected performance setting the vm sizes, networking and disk different options. Here some different options (by default the **demo** option is deployed):

#### Demo

```
netweaver_xscs_vm_size = "Standard_D2s_v3"
netweaver_app_vm_size = "Standard_D2s_v3"
netweaver_data_disk_type = "Premium_LRS"
netweaver_data_disk_size = 128
netweaver_data_disk_caching = ""ReadWrite""
netweaver_xscs_accelerated_networking = false
netweaver_app_accelerated_networking = false
netweaver_app_server_count = 2
```

#### Small

```
netweaver_xscs_vm_size = "Standard_D2s_v3"
netweaver_app_vm_size = "Standard_E64s_v3"
netweaver_data_disk_type = "Premium_LRS"
netweaver_data_disk_size = 128
netweaver_data_disk_caching = ""ReadWrite""
netweaver_xscs_accelerated_networking = false
netweaver_app_accelerated_networking = true
netweaver_app_server_count = 5
```

#### Medium

```
netweaver_xscs_vm_size = "Standard_D2s_v3"
netweaver_app_vm_size = "Standard_E64s_v3"
netweaver_data_disk_type = "Premium_LRS"
netweaver_data_disk_size = 128
netweaver_data_disk_caching = "ReadWrite"
netweaver_xscs_accelerated_networking = false
netweaver_app_accelerated_networking = true
netweaver_app_server_count = 5
```

#### Large

```
netweaver_xscs_vm_size = "Standard_D2s_v3"
netweaver_app_vm_size = "Standard_E64s_v3"
netweaver_data_disk_type = "Premium_LRS"
netweaver_data_disk_size = 128
netweaver_data_disk_caching = "ReadWrite"
netweaver_xscs_accelerated_networking = false
netweaver_app_accelerated_networking = true
netweaver_app_server_count = 10
```

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
