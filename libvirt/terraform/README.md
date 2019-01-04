# Terraform cluster deployment with Libvirt

This terraform module deploys a cluster running the SUSE Linux Enterprise Server
High Availability Extension.

This project is mainly based in [sumaform](https://github.com/moio/sumaform)

## Pending improvements and fixes

Due some IP assignment issues between terraform, libvirt and suse distros, some
workarounds have been done to assign the corresponding IP address to the 2nd
network card (ip_workaround.sls and isolated_network is in "nat" mode).

- https://github.com/dmacvicar/terraform-provider-libvirt/issues/500
- https://github.com/dmacvicar/terraform-provider-libvirt/issues/441

The best thing would be to fix those issues, and developt the salt network state
for suse distros too manage the network configuration properly:

- https://docs.saltstack.com/en/latest/ref/states/all/salt.states.network.html


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

To deploy the cluster only the parameters of two files should be changed: [main.tf](main.tf) and [hana.sls](salt/hana_node/files/pillar/hana.sls).

After changing the values, run the terraform commands:

```bash
terraform init
terraform apply
```

#### main.tf

**main.tf** stores the configuration of the terraform deployment, the infrastructure configuration basically. Here some important tips to update the file properly (all variables are described in each module variables file):

- **uri**: Uri of the libvirt provider.
- **image**: The cluster nodes image is selected updating the *image* parameter in the *base* module. **Disclaimer**: Only the current image in the *main.tf* file has been tested. Other images may not work.
- **iprange**: IP range addresses for the isolated network.
- **name_prefix**: The prefix of our infrastructure components.
- **network_name** and **bridge**: If the cluster is deployed locally, the *network_name* should match with a currently available virtual network. If the cluster is deployed remotely, leave the *network_name* empty and set the *bridge* value with remote machine bridge network interface.
- **sap_inst_media**: Public media where SAPA installation files are stored.
- **host_ips**: Each host IP address (sequential order).
- **additional_repos**: Additional repos to add to the guest machines.

If the current *main.tf* is used, only *uri* (usually SAP HANA cluster deployment needs a powerful machine, not recommended to deploy locally) and *sap_inst_media* parameters must be updated.

#### hana.sls

**hana.sls** is used to configure the SAP HANA cluster. Check the options in: [saphanabootstrap-formula](https://github.com/arbulu89/saphanabootstrap-formula)


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
