# Google Cloud Platform deployment with Terraform

This Terraform configuration deploys SAP HANA in a High-Availability Cluster on SUSE Linux Enterprise Server in the **Google Cloud Platform**.

The infrastructure deployed includes:

- A virtual network with a local subnetwork.
- Rules for access to the instances created.
- Public IP access for the virtual machines via ssh.
- The definition of the image to use in the virtual machines.
- Virtual machines to deploy.

This configuration will create 2 cluster nodes: master & slave.

## Prerequisites

1. First, a GCP account with an active subscription is required.

2. Install the GCloud SDK following the [documentation](https://cloud.google.com/sdk/docs/quickstart-linux)

3. In the [web console](https://console.cloud.google.com/iam-admin/serviceaccounts) create a new personal key for the service account of your project and download the JSON file.

4. Log in with `gcloud init`.

Note: You must run this command to use the Gcloud SDK and to apply this Terraform configuration:

`export GOOGLE_APPLICATION_CREDENTIALS=/path/to/<PROJECT-ID>-xxxxxxxxx.json`

5. A Google Storage bucket must be created with the RAR compressed files containing the HANA installer. 

The bucket may be created and populated with these commands:

```
gsutil mb gs://sap_hana2
gsutil cp 51051635_part* gs://sap_hana2/
```

Note: In this bucket GCP will also store the logs for the deployment, available in the `logs` directory.

Bucket names have more restrictions than object names and must be globally unique, because every bucket resides in a single Cloud Storage namespace. Also, bucket names can be used with a CNAME redirect, which means they need to conform to DNS naming conventions. For more information, see the [bucket naming guidelines](https://cloud.google.com/storage/docs/naming#requirements).

6. A bucket for the images must be created to hold the SLES version to test. 

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

 - [ssh_pub.key](ssh_pub.key): SSH public key to connect to instances.

 - [remote_state.tf](remote_state.tf): definition of the backend to store the Terraform state file remotely. The bucket was created with this [Terraform configuration](create_remote_state/).  Make sure the bucket names match in both configurations.

 - [startup.sh](startup.sh): script to start up the instances.

 - [variables.tf](variables.tf): definition of variables used in the configuration. 
 
 - [terraform.tfvars](terraform.tfvars): defaults for the variables defined in [variables](variables.tf)

## How to use

1. Edit [terraform.tfvars](terraform.tfvars) to suit your needs or use `terraform [-var VARIABLE=VALUE]...` to override defaults.

- The `project` variable must contain the project name.

- The `ip_cidr_range` variable must contain the internal IPv4 range.

- The `sap_vip` variable must contain the virtual IP address for the HANA instances.

- The `machine_type` variable must contain the [GCP machine type](https://cloud.google.com/compute/docs/machine-types).

- The `gcp_credentials_file` variable must contain the path to the JSON file with the GCP credentials created above.

- The `ssh_pub_key_file` variable must contain the path to your SSH public key.

- The `region` variable must contain the name of the desired region.

- The `sap_deployment_debug` variable must be set to `Yes` if you want to debug the deployment.

- The `sap_hana_deployment_bucket` variable must contain the name of the Google Storage bucket with the HANA installation files.

- The `images_path_bucket` must contain the name of the Google Storage bucket with the SLES image.

- The `sles4sap_os_image_file` must contain the name of the SLES image.

- The `post_deployment_script` specifies the URL location of a script to run after the deployment is complete. This script should be hosted on a web server or in a GCS bucket.

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
- This Terraform configuration performs the same process described in the [official GCP documentation for deploying SAP HANA](https://cloud.google.com/solutions/partners/sap/sap-hana-ha-deployment-guide) with the following differences:
  - No NAT configuration for the instances.
  - The former SAP HANA primary is not automatically registered as secondary after takeover.  Edit [startup.sh](startup.sh) if you want to change this.
