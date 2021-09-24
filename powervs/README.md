# IBM Power Systems Virtual Server in IBM Cloud with Terraform and Salt

- [highlevel description](#highlevel-description)
- [quickstart](#quickstart)
- [advanced usage](#advanced-usage)
- [monitoring](../doc/monitoring.md)
- [QA](../doc/qa.md)
- [specification](#specification)

# Highlevel description

This Terraform configuration deploys SAP HANA in a High-Availability Cluster on SUSE Linux Enterprise Server for SAP Applications on **IBM Power Systems Virtual Servers** running in IBM Cloud.

The current infrastructure deployment options that have been tested:

- Must use predefined public and/or private subnet
- Deploy a single HANA instance or highly available HANA instances on a public subnet
- Deploy a single HANA instance or highly available HANA instances on a private subnet through a bastion instance
- Use SNAT for internet connectivity of private subnet instances through bastion
- Customizable storage volume and LVM definition for HANA installation
- Specify a virtual IP address managed by SLE HA Extension for a highly available HANA System Replication deployment
- Deploy a shared storage volume for disk based fencing
- Use IBM Cloud supplied SLES for SAP images (SLES for SAP 12 SP4 currently and more versions are coming)
- Validation using kiwi built SLES for SAP images that are uploaded as PowerVS boot images
- IBM Cloud Object Storage that will be used by salt to download the SAP HANA installation media

Additional options to be enabled and tested:

- Deregister instances from SUSE Customer Center during terraform destroy
- Automate the creation of public and private PowerVS subnets
- Add auto-generating IP address functionality
- Deploy monitoring components for PowerVS
- Deploy NetWeaver landscape components on PowerVS
- Adapt PowerVS terraform and salt for on-prem PowerVC deployments

By default, a highly available configuration with a public and private subnet will create 3 instances:  a bastion instance that is on the public and private subnet and 2 HANA cluster nodes that are on the private subnet.

Once the infrastructure is created by Terraform, the servers are patched, configured and SAP HANA installed with Salt.  A highly available deployment will also install SLE HA Extension and configure the SAPHanaSR resource agents.

# Quickstart

**Note:** This quickstart will guide deploying and accessing a highly available HANA deployment of two instances on a private subnet with a Bastion instance on the public and private subnet

1) **Install IBM Cloud CLI and the power-iaas plugin**

- [Installing the stand-alone IBM Cloud CLI](https://cloud.ibm.com/docs/cli?topic=cli-install-ibmcloud-cli)
- [Extending IBM Cloud CLI with plug-ins](https://cloud.ibm.com/docs/cli?topic=cli-plug-ins)

2) **Define a public and private subnet**

- Use the IBM Cloud web interface to define the subnets naming **public** and **private** respectively
- Use IP range recommendations provided by IBM Cloud

3) **Prepare IBM Cloud Object Storage bucket for SAP media**

- [Getting started with IBM Cloud Object Storage](https://cloud.ibm.com/docs/cloud-object-storage)

4) **Copy terraform.tfvars:** `cp terraform.tfvars.example terraform.tfvars`

Now, terraform.tfvars must be configured to define the deployment.

**Note:** Below is a list of required variables that will assist in a quickstart deployment.  Use the suggested configurations for the options below as well as comments in terraform.tfvars to define the quickstart deployment.

- ibmcloud_api_key
- region
- zone
- pi_cloud_instance_id
- reg_code
  - The SUSE registration code is available from the SUSE Customer Center portal.
- reg_email
  - Your email assigned to your SUSE Customer Center account.
- os_image
  - Use `ibmcloud pi images` for an image ID
- public_key
  - THIS CURRENTLY NEEDS TO BE COMMENTED OUT OR A WARNING IS DISPLAYED.  THIS WILL BE FIXED.
- private_key
- pi_key_pair_name
  - Use `ibmcloud pi keys` for a key name
- pi_sys_type
  - All current testing has been done with "s922"
- public_pi_network_ids
  - Use `ibmcloud pi nets` for a network ID
- public_pi_network_names
  - Use `ibmcloud pi nets` for a network name
- private_pi_network_ids
  - Use `ibmcloud pi nets` for a network ID
- private_pi_network_names
  - Use `ibmcloud pi nets` for a network name
- provisioning_log_level
  - Setting to "trace" is not required.  Enabling trace eases concerns that quickstart has not failed.
- bastion_enabled
  - Set this to true
- bastion_public_key
  - Use the public ssh key pair defined by private_key configuration option
- bastion_private_key
  - Use the private ssh key pair defined by private_key configuration option
- bastion_os_image
  - This option is option unless would like to use a different image for the bastion instance
- bastion_node_vcpu
  - Recommend setting to 2
- bastion_node_memory
  - Recommend setting to 8
- hana_node_vcpu
  - Recommend setting to 4
- hana_node_memory
  - Recommend setting to 64
- hana_count
  - Set to 2
- hana_data_disks_configuration
  - Set disks_size to "20,20,15,15,50,30,50" which provides sufficient space for HANA
- hana_inst_master
- hana_archive_file
- hana_sapcar_exe
- hana_ha_enabled
  - Set this to true
- hana_cluster_vip
  - Use an available IP address in the public subnet

5) **Generate private and public keys for the cluster nodes without specifying the passphrase:**

Alternatively, you can set the `pre_deployment` variable to automatically create the cluster ssh keys.
```
mkdir -p ../salt/sshkeys
ssh-keygen -f ../salt/sshkeys/cluster.id_rsa -q -P ""
```
The key files need to have same name as defined in [terraform.tfvars](terraform.tfvars.example)

6) **[Adapt saltstack pillars manually](../pillar_examples/)** or set the `pre_deployment` variable to automatically copy the example pillar files.

7) If a SLES for SAP 15 or newer image is used for HANA instances, edit ha-sap-terraform-deployments/requirements.yml deleting the three lines that begin with python-shaptools.

You should be able to deploy now.

8) **Deploy**

```
terraform init
```

Continue with the following commands.

```
terraform workspace new myexecution # optional
terraform workspace select myexecution # optional
terraform plan
terraform apply
```

### Destroy the created infrastructure

```
terraform destroy
```

### Use Bastion to access HANA instances

1 ) Use the IBM Cloud web interface to determine the IP addresses assigned to each instance attached to the public and/or private subnets.  

2) Create a file ~/.ssh/config with the following replacing items in brackets.

```
Host default-bastion
  Hostname {bastion public ip address}
  User root
  IdentityFile {/home/myuser/.ssh/id_rsa}

Host default-hana01
  Hostname {hana01 private ip address}
  User root
  IdentityFile {/home/myuser/.ssh/id_rsa}
  ProxyJump default-bastion

Host default-hana02
  Hostname {hana02 private ip address}
  User root
  IdentityFile {/home/myuser/.ssh/id_rsa}
  ProxyJump default-bastion
```

3) Use "ssh default-hana01" to access hana01 through the bastion.

# Specifications

In order to deploy the environment, different configurations are available through the terraform variables. These variables can be configured using a `terraform.tfvars` file. An example is available in [terraform.tfvars.example](./terraform.tvars.example). To find all the available variables check the [variables.tf](./variables.tf) file.

## QA deployment

The project has been created in order to provide the option to run the deployment in a `Test` or `QA` mode. This mode only enables the packages coming properly from SLE channels, so no other packages will be used. Find more information [here](../doc/qa.md).

## Pillar files configuration

Besides the `terraform.tfvars` file usage to configure the deployment, a more advanced configuration is available through pillar files customization. Find more information [here](../pillar_examples/README.md).

# Advanced Usage
TODO
