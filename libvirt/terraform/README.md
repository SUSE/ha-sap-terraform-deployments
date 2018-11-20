# Terraform cluster deployment with Libvirt

This terraform module deploys a cluster running the SUSE Linux Enterprise Server
High Availability Extension.

## Submodules

- **Network**: This submodule sets up an isolated network to enable all cluster
  nodes and shared resources to communicate.
- **Node**: This submodule sets up a machine with SUSE Linux Enterprise Server
  as operating system.
- **Cluster**: This submodule configures a cluster with the existing nodes by
  using Salt. It has a submodule: **HANA**.

## Relevant files

- [variables.tf](variables.tf): In this file all variables for the basic
  deployment are specified with default values. It is recommended to override
  at least the cluster ID when deploying on a QEMU host with other machines to
  prevent collisions.

## How to use

### System requirements

1. You need to have Terraform, the Libvirt provider for Terraform
   `terraform-libvirt-provider` and the Salt provider for Terraform
   `terraform-provider-salt` installed. You also need to install Git.
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
specified in the `variables.tf` file. For the latter
your system requirements will change massively and you might even need a more
powerful machine than your local one.

##### Only overriding few variables

In case you only want to change few values you can simply override them in the
command line:

```Bash
terraform apply -var 'cluster_id=myname' -var 'qemu_uri=qemu:///remote.host'
```

```Bash
TF_VAR_cluster_id="myname" TF_VAR_qemu_uri="qemu:///remote.host" terraform apply
```

**NOTICE** The variable `cluster_id` can only contain a maximum of 8 characters!

However, passing values this way only works for string values.

##### Overriding many variables

When you have many values to override or the variables to be overridden are not
just containing string values you better define the changes in a file. You can
override all variables in the `variables.tf` file by creating a new file with
the suffix `.tfvars`. You can load the file as follows:

```Bash
terraform apply -var_file="my_vars.tfvars"
```

The syntax of this file is the same like in the `variables.tf` file.

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
