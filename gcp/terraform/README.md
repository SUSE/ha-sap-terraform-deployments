# Google Cloud Platform deployment with Terraform

The terraform configuration files in this directory can be used to create the infrastructure required to perform the validation of the public cloud images for SLES for SAP Applications in the **Google Cloud Platform**.

The infrastructure deployed includes:

- A Virtual Network with a local subnet
- A security group with rules for access to the instances created in the subnet. Only allowed external network traffic is for the protocols: SSH, HTTP, HTTPS, and for the HAWK service. Internally to the subnet, all traffic is allowed.
- Public IP access for the virtual machines.
- The definition of the image to use for the virtual machines (image has to be uploaded separately)
- Virtual machines to deploy.

By default, this configuration will create 3 virtual machines in the GCP: one for support services (mainly iSCSI as most other services are provided by GCP), and 2 cluster nodes, but this can be changed to deploy more cluster nodes as needed.

## Relevant files

These are the relevant files and what each provides:

 - [disks.tf](disks.tf): definitions of the storage used for images and virtual machines
 
 - [init-iscsi.tpl](init-iscsi.tpl): template code for the initialization script for the iSCSI server. This will partition the second device and set up the iSCSI targets.
 
 - [init-nodes.tpl](init-nodes.tpl): template code for the initialization script for the cluster nodes. This will connect the cluster nodes to the iSCSI server, configure a wathdog for the cluster, issue a call to `ha-cluster-init` in the master and a call to `ha-cluster-join` in the slaves.
 
 - [instances.tf](instances.tf): definition of the GCP instances to create on deployment.
 
 - [network.tf](network.tf): definition of network resources used by the infrastructure and the firewall rules.
 
 - [outputs.tf](outputs.tf): definition of outputs of the terraform configuration.

 - [provider.tf](provider.tf): definition of the providers being used in the terraform configuration.

 - [ssh_pub.key](ssh_pub.key): SSH public key to connect to instances.

 - [templates.tf](templates.tf): definition of templates to use.

 - [remote_state.tf](remote_state.tf): definition of the backend to store the Terraform state file remotely. The bucket was created with this [Terraform configuration](create_remote_state/).  Make sure the bucket names match in both configurations.

 - [variables.tf](variables.tf): definition of variables used in the configuration. These include definition of the number and type of instances, OS version, region, etc.

### Setup GCP account

First, a GCP account with an active subscription is required.

Log in with `gcloud init`.

Generate JSON credentials file:
  - Navigate to API Manger / Credentials / Create credentials / Service account key in the console.
  - Select Compute Engine default service account and key type JSON

### How to use

To use, copy the files `*.tf` and `*.tpl` into a directory, and then run from the directory the following commands:

```
terraform init
terraform plan -var "date_of_the_day=$(date +%Y%m%d)"
terraform apply -var "date_of_the_day=$(date +%Y%m%d)"
```

### TODO

- Improve documentation
- Remote Terraform state

## Extra info

https://www.terraform.io/docs/providers/google/index.html
