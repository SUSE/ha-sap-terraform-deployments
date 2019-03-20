# Azure Public Cloud deployment with terraform

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

## Relevant files

These are the relevant files and what each provides:

* [provider.tf](provider.tf): definition of the providers being used in the terraform configuration. Mainly azurerm and template.

* [variables.tf](variables.tf): definition of variables used in the configuration. These include definition of the number and type of instances, Azure region, etc.

* [keys.tf](keys.tf): definition of variables with information of key to include in the instances to allow connection via SSH. Edit this to add your own SSH key.

* [resources.tf](resources.tf): definition of the resource group and storage account to use.

* [image.tf](image.tf): definition of the custom image to use for the virtual machines. Edit this to add image blob to use.

* [network.tf](network.tf): definition of network resources (virtual network, subnet, NICs, public IPs and network security group) used by the infrastructure.

* [virtualmachines.tf](virtualmachines.tf): definition of the virtual machines to create on deployment.

* [init-iscsi.sh](init-iscsi.sh): initialization script for the iSCSI server. This will partition the `/dev/sdc` device and set up the iSCSI targets there.

* [init-nodes.sh](init-nodes.sh): initialization script for the cluster nodes. This will connect the cluster nodes to the iSCSI server, configure a watchdog for the cluster, issue a call to ha-cluster-init in the master and a call to ha-cluster-join in the slaves.

* [outputs.tf](outputs.tf): definition of outputs of the terraform configuration.

* [terraform.tfvars.example](terraform.tfvars.example): file containing initialization values for variables used thoughout the configuration. **Rename/Duplicate this file to terraform.tfvars and edit the content with your values before use**.

* [create\_remote\_state.sh](create_remote_state.sh): script used to create a remote Terraform remote state & remote-state.tf

* [remote-state.tf](remote-state.tf): definition of the backend to store the Terraform state file remotely.

## How to upload a custom image

In the terraform configuration we are using a custom image (defined in the file [image.tf](image.tf)) referenced as `azurerm_image.custom.id` in the file [virtualmachines.tf](virtualmachines.tf) (in the `storage_image_reference` block).

This custom image needs to be already uploaded to Azure before attempting to use it with terraform, as terraform does not have a mechanism to upload images as of yet.

In order to upload images for further use in terraform, use the procedure defined in the [Upload a custom image](#upload-custom-image) section below. Be sure to set up your Azure account first with the azure-cli to be able to follow that procedure.

On the other hand, if there is a need to use publicly available images, the `storage_image_reference` block in the virtual machines definition (file [virtualmachines.tf](virtualmachines.tf)) should look like this:

```
storage_image_reference {
  publisher = "SUSE"
  offer     = "SLES-SAP-BYOS"
  sku       = "12-SP3"
  version   = "2018.08.17"
}
```

To check the values for publisher, offer, sku and version of the available public images, use the command `az vm image list --output table`. For example, to check for the public images from SUSE available in Azure:

```
az vm image list --output table --publisher SUSE --all
```

The file [virtualmachines.tf-publicimg](virtualmachines.tf-publicimg) is a copy of [virtualmachines.tf](virtualmachines.tf) but using the `SUSE SLES-SAP-BYOS 12-SP3` public image referenced above instead of a private image. Rename that file as [virtualmachines.tf](virtualmachines.tf) to use that OS image with this configuration or edit the `storage_image_reference` as needed to use a different public image.

If using a public image, skip to the [how to use section](#how-to-use).

### Setup Azure account

First, an Azure account with an active subscription is required.

Log in with `az login` and check that the account has subscriptions with `az account list`. It should show you an entry for the tenant, and at least an entry for a subscription.

Then set the default subscription with the command `az account set`, for example, we are using the **"SUSE R&D General"** subscription, so we define that as the default subscription with:

```
az account set --subscription "SUSE R&D General"
```

To verify which subscription is the active one, use the command `az account show`.

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

This URI will be used in the terraform configuration, specifically in the [image.tf](image.tf) file or via the command line, so keep it on hand.

### Remove resources

To remove resources, substitute show for delete in all check commands. For example:

```
az storage blob delete --name SLES12-SP4-SAP-Azure-BYOS.x86_64-0.9.0-Build2.1.vhd --container-name MyStorageContainer --account-name MyStorageAccount
```

Will delete blob `SLES12-SP4-SAP-Azure-BYOS.x86_64-0.9.0-Build2.1.vhd` from storage container `MyStorageContainer`.

## How to use

To use, copy the `*.tf`, `*.sh` and `terraform.tfvars` files and the `provision` directory into your working directory.

Then, from your working directory, generate private and public keys for the cluster nodes with the following commands:

```
ssh-keygen -t rsa -f provision/node0_id_rsa
ssh-keygen -t rsa -f provision/node1_id_rsa
```

The key files need to be named `node0_id_rsa`, `node0_id_rsa.pub`, `node1_id_rsa` and `node1_id_rsa.pub` as the initialization scripts expect those names, so check for those files in the `provisioning` sub-directory after generating the keys.

Following that edit the following files:

* [terraform.tfvars](terraform.tfvars): add the URI of the image blob to test if using a private OS image; add the admin user, its private key location on the local machine and the SSH public key from that private key.
* [provider.tf](provider.tf): add the subscription id, client id, client secret and tenant id from you Azure account.

When using local terraform state files, remove the [remote-state.tf](remote-state.tf) file from the directory before any terraform commands; otherwise, if using remote terraform state file and it is not defined in [remote-state.tf](remote-state.tf), run the script [create\_remote\_state.sh](create_remote_state.sh) and pay attention to the last line. Then run `export ARM_ACCESS_KEY=xxxxxxx` as instructed by the script.

Then deploy the infrastructure from the directory by running the following commands:

```
terraform init
terraform plan
terraform apply
```

**Important**: Remember to rename [virtualmachines.tf-publicimg](virtualmachines.tf-publicimg) to [virtualmachines.tf](virtualmachines.tf) if using a public OS image.

It is also recommended to run the apply command with a timeout, as not all errors are easily detected by the terraform Azure provider, and you can run into a scenario where the infrastructure is apparently still being deployed for a long period (over 15 or 20 minutes), but it is actually broken or failing in the cloud.

```
timeout 15m terraform apply
```

Keep in mind that in the event of a timeout, there is a possibility that you will be required to remove the deployed infrastructure manually, as `terraform destroy` may not work.

After an apply command, terraform will deploy the insfrastructure to the cloud and ouput the public IP addresses and names of the iSCSI server and the cluster nodes. Connect using ssh and the user defined in [terraform.tfvars](terraform.tfvars), for example:

```
ssh myadminuser@168.63.27.167
```

Destroy the created infrastructure with:

```
terraform destroy
```

Check outputs with:

```
terraform output
```

Refresh resources with (for example, if one of the init script failed during `apply` but the infrastructure was successfully created):

```
terraform refresh
```

By default, the infrastructure is being deployed to the `westeurope` region of Azure. This can be changed by reassigning the variable `az_region` currently defined in the [terraform.tfvars](terraform.tfvars) file. For example, with the command:

```
terraform apply -var az_region=eastus
```

The virtual machines for the cluster nodes are created by default with the size `Standard_E4s_v3`, this can be changed with the option -var instancetype. For example the command:

```
terraform apply -var instancetype=Standard_D8s_v3
```

Will deploy 2 `Standard_D8s_v3` virtual machines in the West Europe zone, instead of the `Standard_E4s_v3` default ones. The iSCSI server is always deployed as a `Standard_D2s_v3` sized virtual machine.

Finally, the number of cluster nodes can be modified with the option -var ninstances. For example:

```
terraform apply -var ninstances=4
```

Will deploy in the West Europe zone 1 `Standard_D2s_v3` sized virtual machine as iSCSI server and 4 `Standard_E4s_v3` as cluster nodes.

All this means that basically the default command `terraform apply` and be also written as `terraform apply -var az_region=westeurope -var instancetype=Standard_E4s_v3 -var ninstances=2`.

### Variables

In the file [terraform.tfvars](terraform.tfvars) there are a number of variables that control what is deployed. Some of these variables are:

* **admin_user**: name of the administration user to deploy in all virtual machines.
* **private_key_location**: path to the local file containing the private SSH key to configure in the virtual machines to allow access.
* **public_key**: SSH public key associated with the private key file. This public key is configured in the file `$HOME/.ssh/authorized_keys` of the administration user in the remote virtual machines.
* **instmaster**: path to a SMB/CIFS share containing the installation master of Hana.
* **instmaster_user**: user to use to connect to the previous share.
* **instmaster_pass**: password to use to connect to the previous share.
* **image_uri**: URI to the BLOB where the VHD file of the image to use to launch the VMs is located. This is only used when deploying the virtual machines with a custom/private OS image. Check [elsewhere in this document](#how-to-upload-a-custom-image) for information on how to change the configuration in order to use a public image.
* **instancetype**: SKU to use for the cluster nodes; basically the "size" (number of vCPUS and memory) of the VM.
* **ninstances**: number of cluster nodes to deploy. Defaults to 2.
* **az_region**: Azure region where to deploy the configuration.
* **init-type**: initilization script parameter that controls what is deployed in the cluster nodes. Valid values are `all` (installs Hana and configures cluster), `skip-hana` (does not install Hana, but configures cluster) and `skip-cluster` (installs hana, but does not configure cluster). Defaults to `all`.

## Relevant Details

There are some fixed values used throughout the terraform configuration:

- The private IP address of the iSCSI server is set to 10.74.1.10 and its hostname is `iscsisrv`.
- The cluster nodes are created with private IPs starting with 10.74.1.11 and finishing in 10.74.1.22. More addresses can be added to the array in [network.tf](network.tf). The hostnames of these virtual machines go from `node-0` to `node-11`. The virtual machine named `node-0` is used initially as the master node of the cluster, ie, the node where `ha-cluster-init` is run.
- The iSCSI server has a second disk volume that is being configured as the `/dev/sdc` block device.
- The [init-iscsi.sh](init-iscsi.sh) script is partitioning this device in 10 1MB partitions, from `sdc1` to `sdc10` and then configuring this as LUNs 0 to 9 for iSCSI.
- iSCSI LUN 9 is being used in the cluster as SBD device.
- The cluster nodes have a second disk volume that is being configured as the `/dev/sdc` block device. This is used for Hana installation.
- The iSCSI server init script leaves a log in the file `init-iscsi.log` located in the home directory of the admin user.
- The cluster nodes init script leaves a log in the file `init-nodes.log` located in the home directory of the admin user.

## Logs

This configuration is leaving logs of the initializations scripts in the home directory of the remote admin user in each of the virtual machines. So connect as `ssh <admin_user>@<remote_ip>` and check the following files:

* **init-iscsi.log**: only present in the iSCSI server. Check here the output of the commands used to set up the iSCSI target in the virtual machine.
* **init-nodes.log**: present in the cluster nodes. Check here the output of the commands to set up the watchdog, iSCSI client, NTP server, HANA installation and cluster setup in each of the nodes.

## Configure Terraform Access to Azure

To setup access to Azure via Terraform, four parameters are required:

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

### In provider definition

Add the values for subscription id, tenant id, client id and client secret in the file [provider.tf](provider.tf).

### Via Environment Variables

Set the following environment variables before running terraform:

```
export ARM_SUBSCRIPTION_ID=your_subscription_id
export ARM_CLIENT_ID=your_appId
export ARM_CLIENT_SECRET=your_password
export ARM_TENANT_ID=your_tenant_id
export ARM_ACCESS_KEY=access_key
```

## Pending/To Do

* HA Cluster resource templates include fixed IP adddresses and host names specific to this Azure terraform configuration. It would be helpful to change these files into proper templates so they can be used with AWS and GCP as well.
* More tests with a working fixed configuration just to be sure that it is always working. The smallest VM sizes have presented problems, causing `terraform apply` to stay creating the VMs for over 15 minutes, failing to upload boot information, and also affecting `terraform destroy` after `terraform apply` times out.
* Command line to determine whether there is enough quota available in the intended deployment zone for the resources, as an interrupted `terraform apply` command due to quotas, usually require the removal of the resources by hand.
* The contents of the [provision](provision) subdirectory are the same between AWS and Azure configuration, so it could be useful to also move [init-nodes.sh](init-nodes.sh) and [init-iscsi.sh](init-iscsi.sh) there as long as the same code can be used without changes in all public cloud providers. For the moment, provision in AWS configuration points to the Azure configuration files.
* This configuration is adding a `dlm` resource to the cluster, which is not available by default in SUSE Linux Enterprise Server for SAP Applications for public clouds prior to 12-SP4.
* Add a prefix variable to resources that require unique names in Azure such as storage accounts and DNS names.
* Salt everything?

## Extra info

More info in [Azure's Terraform Create Complete VM Document](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-create-complete-vm).

Also check the documentation in https://www.terraform.io/docs.
