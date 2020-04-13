# Terraform cluster deployment with Libvirt

# Table of content:

- [Requirements](#requirements)
- [Howto](#quickstart)
- [Monitoring](../doc/monitoring.md)
- [Netweaver](../doc/netweaver.md)
- [DRBD](../doc/drbd.md)
- [QA](../doc/qa.md)
- [Design](#design)
- [Specifications](#specifications)
- [Troubleshooting](#troubleshooting)

# Requirements

1. You need to have Terraform and the the Libvirt provider for Terraform. You may download packages from the
   [openSUSE Build Service](http://download.opensuse.org/repositories/systemsmanagement:/terraform/) or
   [build from source](https://github.com/dmacvicar/terraform-provider-libvirt)

   You will need to have a working libvirt/kvm setup for using the libvirt-provider. (refer to upstream doc of [libvirt provider](https://github.com/dmacvicar/terraform-provider-libvirt))

2. You need to fulfill the system requirements provided by SAP for each Application. At least 15 GB of free disk space and 512 MiB of free memory per node.

# Quickstart

1) Make sure you use terraform workspaces, create new one with: ```terraform workspace new $USER```

  For more doc, see: [workspace](../doc/workspaces-workflow.md).
  If you don't create a new one, the string `default` will be used as workspace name. This is however highly discouraged since the workspace name is used as prefix for resources names, which can led to conflicts to unique names in a shared server ( when using a default name).

2) Edit the `terraform.tfvars.example` file, following the Readme.md in the provider directory.

3) **[Adapt saltstack pillars](../pillar_examples/)**

4) Deploy with:

```bash
terraform workspace new myworkspace # The workspace name will be used to create the name of the created resources as prefix (`default` by default)
terraform init
terraform apply
terraform destroy
```

# Design

This project is mainly based in [sumaform](https://github.com/uyuni-project/sumaform/)

Components:

- **modules**: Terraform modules to deploy a basic two nodes SAP HANA environment.
- **salt**: Salt provisioning states to configure the deployed machines with the
all required components.


### Terraform modules
- [hana_node](modules/hana_node): Specific SAP HANA node defintion. Basically it calls the
host module with some particular updates.
- [netweaver_node](modules/netweaver_node): SAP Netweaver environment allows to have
a Netweaver landscape working with the SAP Hana database.
- [drbd_node](modules/drbd_node): DRBD cluster for NFS share.
- [iscsi_server](modules/iscsi_server): Machine to host a iscsi target.
- [monitoring](modules/monitoring): Machine to host the monitoring stack.
- [shared_disk](modules/shared_disk): Shared disk, could be used as a sbd device.

### Salt modules
- [pre_installation](../salt/pre_installation): Adjust the configuration needed for
defult module.
- [default](../salt/default): Default configuration for each node. Install the most
basic packages and apply basic configuration.
- [hana_node](../salt/hana_node): Apply SAP HANA nodes specific updates to install
SAP HANA and enable system replication according [pillar](../pillar_examples/libvirt/hana.sls)
data. You can also use the provided [automatic pillars](../pillar_examples/automatic/hana).
- [drbd_node](../salt/drbd_node): Apply DRBD nodes specific updates to configure
DRBD cluster for NFS share according [drbd pillar](../pillar_examples/libvirt/drbd/drbd.sls)
and [cluster pillar](../pillar_examples/libvirt/drbd/cluster.sls). You can also use the
provided [automatic pillars](../pillar_examples/automatic/drbd).
- [monitoring](../salt/monitoring): Apply prometheus monitoring service configuration.
- [iscsi_srv](../salt/iscsi_srv): Apply configuration for iscsi target.
- [netweaver_node](../salt/netweaver_node): Apply netweaver packages and formula.
- [qa_mode](../salt/qa_mode): Apply configuration for Quality Assurance testing.

# Specifications

In order to deploy the environment, different configurations are available through the terraform variables. This variables can be configured using a `terraform.tfvars` file. An example is available in [terraform.tfvars.example](./terraform.tvars.example). To find all the available variables check the [variables.tf](./variables.tf) file.

## QA deployment

The project has been created in order to provide the option to run the deployment in a `Test` or `QA` mode. This mode only enables the packages coming properly from SLE channels, so no other packages will be used. Find more information [here](../doc/qa.md).

## Pillar files configuration

Besides the `terraform.tfvars` file usage to configure the deployment, a more advanced configuration is available through pillar files customization. Find more information [here](../pillar_examples/README.md).

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
