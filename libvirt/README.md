# Terraform cluster deployment with Libvirt

# Table of content:

- [Requirements](#requirements)
- [Howto](#quickstart)
- [Design](#design)
- [Specifications](#specifications)
- [Troubleshooting](#troubleshooting)

For detailed documentation see:

- [Monitoring](../doc/monitoring.md)
- [S/4HANA and NetWeaver](../doc/netweaver.md)
- [DRBD](../doc/drbd.md)

# Requirements

1. You need to have Terraform and the the Libvirt provider for Terraform. You may download packages from the
   [openSUSE Build Service](http://download.opensuse.org/repositories/systemsmanagement:/terraform/) or
   [build from source](https://github.com/dmacvicar/terraform-provider-libvirt)

   You will need to have a working libvirt/kvm setup for using the libvirt-provider. (refer to upstream doc of [libvirt provider](https://github.com/dmacvicar/terraform-provider-libvirt))

   You need the xslt processor `xsltproc` installed on the system. With it terraform is able to process xsl files.

2. You need to fulfill the system requirements provided by SAP for each Application. At least 15 GB of free disk space and 512 MiB of free memory per node.

# Quickstart

1) Make sure you use terraform workspaces, create new one with: ```terraform workspace new $USER```

  For more doc, see: [workspace](../doc/workspaces-workflow.md).
  If you don't create a new one, the string `default` will be used as workspace name. This is however highly discouraged since the workspace name is used as prefix for resources names, which can led to conflicts to unique names in a shared server ( when using a default name).

2) Edit the `terraform.tfvars.example` file.

**Note:** Find some help in the IP addresses configuration in [IP auto generation](../doc/ip_autogeneration.md#Libvirt)

3) **[Adapt saltstack pillars manually](../pillar_examples/)** or set the `pre_deployment` variable to automatically copy the example pillar files.

4) Deploy with:

```bash
terraform workspace new myworkspace # The workspace name will be used to create the name of the created resources as prefix (`default` by default)
terraform init
terraform apply
terraform destroy
```

# Specifications

In order to deploy the environment, different configurations are available through the terraform variables. These variables can be configured using a `terraform.tfvars` file. An example is available in [terraform.tfvars.example](./terraform.tvars.example). To find all the available variables check the [variables.tf](./variables.tf) file.

## QA deployment

The project has been created in order to provide the option to run the deployment in a `Test` or `QA` mode. This mode only enables the packages coming properly from SLE channels, so no other packages will be used. The mode is selected by setting the variable offline_mode to true.

## Pillar files configuration

Besides the `terraform.tfvars` file usage to configure the deployment, a more advanced configuration is available through pillar files customization. Find more information [here](../pillar_examples/README.md).

## Use already existing network resources

The usage of already existing network resources (virtual network and images) can be done configuring
the `terraform.tfvars` file and adjusting some variables. The example of how to use them is available
at [terraform.tfvars.example](terraform.tfvars.example).

# Troubleshooting

### Resources have not been destroyed

Sometimes it happens that created resources are left after running
`terraform destroy`. It happens especially when the `terraform apply` command
was not successful and you tried to destroy the setup in order of resetting the
state of your terraform deployment to zero.
It is often helpful to simply run `terraform destroy` again. However, even when
it succeeds in this case you might still want to check manually for remaining
resources.

For the following commands you need to use the command line tool Virsh. You can
retrieve the QEMU URI Virsh is currently connected to by running the command
`virsh uri`.

#### Checking networks

You can run `virsh net-list --all` to list all defined Libvirt networks. You can
delete undesired ones by executing `virsh net-undefine <network_name>`, where
`<network_name>` is the name of the network you like to delete.

#### Checking domains

For each node a domain is defined by Libvirt in order to address the specific
machine. You can list all domains by running the command `virsh list`. When you
like to delete a domain you can run `virsh undefine <domain_name>` where
`<domain_name>` is the name of the domain you like to delete.

#### Checking images

In case you experience issues with your images such as install ISOs for
operating systems or virtual disks of your machine check the following folder
with elevated privileges: `sudo ls -Faihl /var/lib/libvirt/images/`

#### Packages failures

If some package installation fails during the salt provisioning, the
most possible thing is that some repository is missing.
Add the new repository with the needed package and try again.
