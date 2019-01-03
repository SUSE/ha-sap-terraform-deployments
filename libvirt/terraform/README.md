# Terraform cluster deployment with Libvirt

This terraform module deploys a cluster running the SUSE Linux Enterprise Server
High Availability Extension.

This project is mainly based in [sumaform](https://github.com/moio/sumaform)

## Pending improvements and fixes

Currently this project is not totally operative due some terraform/libvirt current
limitations:
- https://github.com/dmacvicar/terraform-provider-libvirt/issues/500
- https://github.com/dmacvicar/terraform-provider-libvirt/issues/441

Due this issue, static IP assigment is not still working and this feature is
mandatory for SAP HANA proper deployment.

Besides that, there are many things still to be done:
- Set the proper SLES4SAP hana images
- Polish the not used variables (mainly copied from sumaform)
- Test sbd current usage (and add iSCSI server option)
- Install and enable HA Cluster functionalities

## Main components

- **modules**: Terraform modules to deploy a basic two nodes SAP HANA environment.
- **salt**: Salt provisioning states to configure the deployed machines with the
all required components.

## Relevant files

### Terraform modules
- [base](modules/base): Base configuration of the cluster. The used SLES images, private
network and generic data are managed here.
- [host](modules/host): The generic SAP HANA node definition. This modules defines the most
important features of the each node (attach used partitions, networks, OS parameters, etc).
- [hana_node](modules/hana_node): Specific SAP HANA node defintion. Basically it call the
host module with some particular updates.
- [sbd](modules/sbd): SBD device definition. Currently a shared disk.

### Salt modules
- [default](salt/default): Default configuration for each node. Install the most
basic packages and apply basic configuration.
- [hana_node](salt/hana_node): Apply SAP HANA nodes specific updates to install
SAP HANA and enable system replication according [pillar](salt/hana_node/files/pillar/hana.sls)
data.

## How to use

### System requirements

1. You need to have Terraform, the Libvirt provider for Terraform
   `terraform-libvirt-provider`.
1. You need at least 15 GB of free disk space and 512 MiB of free memory per
   node.
1. You need to have a working libvirt setup and sufficient privileges to connect
   and create virtual machines, networks and disks.

### Deployment

#### Using default values

When you meet the system requirements testing the deployment of a SUSE HA
cluster on your local machine is very easy. Just clone this repository to a
desired place, navigate in the subfolder `libvirt/terraform` of the project and
run `terraform init` and `terraform apply`. You will be displayed a summary what
terraform will do. After typing `yes` and pressing `enter` terraform will set up
your cluster. Although this works for most people, **check the default values
and the terraform plan whether it harmonizes with your libvirt setup before
applying the plan.**

#### Customize your cluster

When you like to have different performance parameters or want to set up an SAP
HANA System Replication, you need to alter the default values of the variables
specified in the `main.tf` file. For the latter
your system requirements will change massively and you might even need a more
powerful machine than your local one.


### Destroying the cluster

The command `terraform destroy` deletes all resources that Terraform has
created.

## Troubleshooting

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
