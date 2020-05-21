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
terraform workspace new myexecution # optional
terraform workspace select myexecution # optional
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
- The created HA environment uses the route table option to forward the coming requests and manage the floating IP address of the cluster (gcp-vpc-move-route resource agent).

By default, this configuration will create 3 instances in GCP: one for support services (mainly iSCSI as most other services - DHCP, NTP, etc - are provided by Google) and 2 cluster nodes, but this can be changed to deploy more cluster nodes as needed.

# Specifications

In order to deploy the environment, different configurations are available through the terraform variables. These variables can be configured using a `terraform.tfvars` file. An example is available in [terraform.tfvars.example](./terraform.tvars.example). To find all the available variables check the [variables.tf](./variables.tf) file.

## QA deployment

The project has been created in order to provide the option to run the deployment in a `Test` or `QA` mode. This mode only enables the packages coming properly from SLE channels, so no other packages will be used. Find more information [here](../doc/qa.md).

## Pillar files configuration

Besides the `terraform.tfvars` file usage to configure the deployment, a more advanced configuration is available through pillar files customization. Find more information [here](../pillar_examples/README.md).

## Use already existing network resources

The usage of already existing network resources (vpc, subnet, firewall rules, etc) can be done configuring
the `terraform.tfvars` file and adjusting some variables. The example of how to use them is available
at [terraform.tfvars.example](terraform.tfvars.example).

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
