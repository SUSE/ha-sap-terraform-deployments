# Google Cloud Platform deployment with Terraform and Salt

* [Quickstart](#quickstart)
   * [Bastion](#bastion)
* [Highlevel description](#highlevel-description)
* [Customization](#customization)
   * [QA deployment](#qa-deployment)
   * [Pillar files configuration](#pillar-files-configuration)
   * [Use already existing network resources](#use-already-existing-network-resources)
* [Advanced Customization](#advanced-customization)
   * [Terraform Parallelism](#terraform-parallelism)
   * [How to upload SAP install sources](#how-to-upload-sap-install-sources)
   * [How to upload a custom image](#how-to-upload-a-custom-image)
* [Troubleshooting](#troubleshooting)

This sub directory contains the cloud specific part for usage of this
repository with Google Cloud Platform (GCP). Looking for another provider? See
[Getting started](../README.md#getting-started)


# Quickstart

This is a very short quickstart guide. For detailed information see [Using SUSE Automation to Deploy an SAP HANA Cluster on GCP - Getting Started🔗](https://documentation.suse.com/sbp/all/single-html/TRD-SLES-SAP-HA-automation-quickstart-cloud-gcp/).

For detailed information and deployment options have a look at `terraform.tfvars.example`.

1) **Rename terraform.tfvars:**

    ```
    mv terraform.tfvars.example terraform.tfvars
    ```

    Now, the created file must be configured to define the deployment.

    **Note:** Find some help in for IP addresses configuration below in [Customization](#customization).

2) **Generate private and public keys for the cluster nodes without specifying the passphrase:**

    Alternatively, you can set the `pre_deployment` variable to automatically create the cluster ssh keys.

    ```
    mkdir -p ../salt/sshkeys
    ssh-keygen -f ../salt/sshkeys/cluster.id_rsa -q -P ""
    ```

	The key files need to have same name as defined in [terraform.tfvars](./terraform.tfvars.example).

3) **[Adapt saltstack pillars manually](../pillar_examples/)** or set the `pre_deployment` variable to automatically copy the example pillar files.

4) **Configure Terraform access to GCP**

    - First, a GCP account with an active subscription is required.

    - Install the GCloud SDK following Google's [documentation🔗](https://cloud.google.com/sdk/docs/quickstart-linux)

    - Create a new personal key for the service account of [your google cloud project🔗](https://console.cloud.google.com/apis/credentials/serviceaccountkey?_ga=2.91196186.-1602867212.1565799790.).

      See also [GCP with terraform tutorial🔗](https://cloud.google.com/community/tutorials/getting-started-on-gcp-with-terraform)

    - Log in with `gcloud init`.

      Note: You must run this command to use the Gcloud SDK and to apply this Terraform configuration:

      ```
      export GOOGLE_APPLICATION_CREDENTIALS=/path/to/<PROJECT-ID>-xxxxxxxxx.json
      ```

5) **Deploy**

    The deployment can now be started with:

    ```
    terraform init
    terraform workspace new myexecution # optional
    terraform workspace select myexecution # optional
    terraform plan
    terraform apply
    ```

    To get rid of the deployment, destroy the created infrastructure with:

    ```
    terraform destroy
    ```


## Bastion

By default, the bastion machine is enabled in GCP (it can be disabled), which will have the unique public IP address of the deployed resource group. Connect using ssh and the selected admin user with:

```
ssh {admin_user}@{bastion_ip} -i {private_key_location}
```

To log to hana and others instances, use:

```
ssh -o ProxyCommand="ssh -W %h:%p {admin_user}@{bastion_ip} -i {private_key_location} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" {admin_user}@{private_hana_instance_ip} -i {private_key_location} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
```

To disable the bastion use:

```
bastion_enabled = false
```

Destroy the created infrastructure with:

```
terraform destroy
```

# Highlevel description

This Terraform configuration deploys SAP HANA in a High-Availability Cluster on SUSE Linux Enterprise Server for SAP Applications in the **Google Cloud Platform**.

![Highlevel description](../doc/highlevel_description_gcp.png)

The infrastructure deployed includes:

* virtual network
* subnets within the virtual network.
* firewall group with rules for access to the instances created in the subnet. Only allowed external network traffic is for the protocols: SSH, HTTP, HTTPS, and for the HAWK service. Internally to the subnet, all traffic is allowed.
* Public IP access for the virtual machines (if enabled)
* compute instance groups
* load balancers
* virtual machines
* block devices
* shared filestore filesystems (if enabled)

By default, this configuration will create 3 instances in GCP: one for support services (mainly iSCSI as most other services - DHCP, NTP, etc - are provided by Google) and 2 cluster nodes, but this can be changed to deploy more cluster nodes as needed.

# Customization

In order to deploy the environment, different configurations are available through the terraform variables. These variables can be configured using a `terraform.tfvars` file. An example is available in [terraform.tfvars.example](./terraform.tvars.example). To find all the available variables check the [variables.tf](./variables.tf) file.

## QA deployment

The project has been created in order to provide the option to run the deployment in a `Test` or `QA` mode. This mode only enables the packages coming properly from SLE channels, so no other packages will be used. Set `offline_mode = true` in `terraform.tfvars` to enable it.

## Pillar files configuration

Besides the `terraform.tfvars` file usage to configure the deployment, a more advanced configuration is available through pillar files customization. Find more information [here](../pillar_examples/README.md).

## Use already existing network resources

The usage of already existing network resources (vpc, subnet, firewall rules, etc) can be done configuring
the `terraform.tfvars` file and adjusting some variables. The example of how to use them is available
at [terraform.tfvars.example](terraform.tfvars.example).

## Autogenerated network addresses

The assignment of the addresses of the nodes in the network can be automatically done in order to avoid
this configuration. For that, basically, remove or comment all the variables related to the ip addresses (more information in [variables.tf](variables.tf)). With this approach all the addresses are retrieved based in the provided virtual network addresses range (`vnet_address_range`).

**Note:** If you are specifying the IP addresses manually, make sure these are valid IP addresses. They should not be currently in use by existing instances. In case of shared account usage, it is recommended to set unique addresses with each deployment to avoid using same addresses.

Example based on `10.0.0.0/24` VPC address range. The virtual addresses must be outside of the VPC address range.

| Service                          | Variable                     | Addresses                                          | Comments                                                                                               |
| ----                             | --------                     | ---------                                          | --------                                                                                               |
| iSCSI server                     | `iscsi_srv_ip`               | `10.0.0.4`                                         |                                                                                                        |
| Monitoring                       | `monitoring_srv_ip`          | `10.0.0.5`                                         |                                                                                                        |
| Bastion                          | -                            | `10.0.2.5`                                         |                                                                                                        |
| HANA IPs                         | `hana_ips`                   | `10.0.0.10`, `10.0.0.11`                           |                                                                                                        |
| HANA cluster vIP                 | `hana_cluster_vip`           | `10.0.1.12`                                        | Only used if HA is enabled in HANA                                                                     |
| HANA cluster vIP secondary       | `hana_cluster_vip_secondary` | `10.0.1.13`                                        | Only used if the Active/Active setup is used                                                           |
| DRBD IPs                         | `drbd_ips`                   | `10.0.0.20`, `10.0.0.21`                           |                                                                                                        |
| DRBD cluster vIP                 | `drbd_cluster_vip`           | `10.0.1.22`                                        |                                                                                                        |
| S/4HANA or NetWeaver IPs         | `netweaver_ips`              | `10.0.0.30`, `10.0.0.31`, `10.0.0.32`, `10.0.0.33` | Addresses for the ASCS, ERS, PAS and AAS. The sequence will continue if there are more AAS machines    |
| S/4HANA or NetWeaver virtual IPs | `netweaver_virtual_ips`      | `10.0.1.34`, `10.0.1.35`, `10.0.1.36`, `10.0.1.37` | The first virtual address will be the next in the sequence of the regular S/4HANA or NetWeaver addresses |

# Advanced Customization

## Terraform Parallelism

When deploying many scale-out nodes, e.g. 8 or 10, you should must pass the [`-nparallelism=n`🔗](https://www.terraform.io/docs/cli/commands/apply.html#parallelism-n) parameter to `terraform apply` operations.

It "limit[s] the number of concurrent operation as Terraform walks the graph."

The default value of `10` is not sufficient because not all HANA cluster nodes will get provisioned at the same. A value of e.g. `30` should not hurt for most use-cases.

## How to upload SAP install sources

Details on which installation sources are needed can be found in the [SAP software documentation](../doc/sap_software.md).

A Google Storage bucket must be created with the files containing the HANA installer.

The bucket may be created and populated with these commands:

This is an example where **51053381** is the targeted HANA version to upload.
```
gsutil mb gs://sap_instmasters/51053381/
gsutil cp 51053381/ gs://sap_instmasters/51053381/
```

Bucket names have more restrictions than object names and must be globally unique, because every bucket resides in a single Cloud Storage namespace. Also, bucket names can be used with a CNAME redirect, which means they need to conform to DNS naming conventions. For more information, see the [bucket naming guidelines🔗](https://cloud.google.com/storage/docs/naming#requirements).

## How to upload a custom image

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

# Troubleshooting

In case you have some issue, take a look at this [troubleshooting guide](../doc/troubleshooting.md).
