# Terraform cluster deployment with Libvirt

This terraform module deploys a cluster running the SUSE Linux Enterprise Server
High Availability Extension.

This project is mainly based in [sumaform](https://github.com/moio/sumaform)

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
- [hana_node](modules/hana_node): Specific SAP HANA node defintion. Basically it calls the
host module with some particular updates.
- [sbd](modules/sbd): SBD device definition. Currently a shared disk.

### Salt modules
- [default](../../salt/default): Default configuration for each node. Install the most
basic packages and apply basic configuration.
- [hana_node](../../salt/hana_node): Apply SAP HANA nodes specific updates to install
SAP HANA and enable system replication according [pillar](../../salt/hana_node/files/pillar/hana.sls)
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

To deploy the cluster only the parameters of three files should be changed: [main.tf](main.tf), [hana.sls](salt/hana_node/files/pillar/hana.sls) and [cluster.sls](salt/hana_node/files/pillar/cluster.sls).
Configure these files according the wanted cluster type.

Find more information about the hana and cluster formulas in (check the pillar.example files):
- https://github.com/SUSE/saphanabootstrap-formula
- https://github.com/krig/habootstrap-formula


In order to enable the cluster creation, ssh keys must be shared between the nodes. For that create new ssh keys (are use already created ones) and copy them in salt/hana_node/files/sshkeys/ .

The easiest way to customize the variables is using a *terraform.tfvars* file.
Here an example:

```bash
qemu_uri = "qemu+ssh://root@your_machine/system"
sap_inst_media = "path_to_nfs_server"
base_image = "path_to_image"
name_prefix = "demo"
iprange = "192.168.101.0/24"
host_ips = ["192.168.101.15", "192.168.101.16"]
additional_repos = {
    "repo_1" = "url_repo1"
    "repo_1" = "url_repo1"
    "repo_1" = "url_repo1"
}
"cluster_ssh_pub = salt://hana_node/files/sshkeys/my_key.id_rsa.pub"
"cluster_ssh_key = salt://hana_node/files/sshkeys/my_key.id_rsa"
```

After changing the values, run the terraform commands:

```bash
terraform init
terraform apply -var-file=terraform.tfvars
```

**Info**: If some package installation fails during the salt provisioning, the
most possible thing is that some repository is missing. Add the new repository
with the needed package and try again.

#### main.tf

**main.tf** stores the configuration of the terraform deployment, the infrastructure configuration basically. Here some important tips to update the file properly (all variables are described in each module variables file):

- **qemu_uri**: Uri of the libvirt provider.
- **base_image**: The cluster nodes image is selected updating the *image* parameter in the *base* module.
- **name_prefix**: The prefix of our infrastructure components.
- **network_name** and **bridge**: If the cluster is deployed locally, the *network_name* should match with a currently available virtual network. If the cluster is deployed remotely, leave the *network_name* empty and set the *bridge* value with remote machine bridge network interface.
- **sap_inst_media**: Public media where SAPA installation files are stored.
- **iprange**: IP range addresses for the isolated network.
- **host_ips**: Each host IP address (sequential order).
- **cluster_ssh_pub**: SSH public key name (must match with the key copied in sshkeys folder)
- **cluster_ssh_key**: SSH private key name (must match with the key copied in sshkeys folder)
- **additional_repos**: Additional repos to add to the guest machines.

If the current *main.tf* is used, only *uri* (usually SAP HANA cluster deployment needs a powerful machine, not recommended to deploy locally) and *sap_inst_media* parameters must be updated.

#### hana.sls

**hana.sls** is used to configure the SAP HANA cluster. Check the options in: [saphanabootstrap-formula](https://github.com/arbulu89/saphanabootstrap-formula)

#### cluster.sls

**cluster.sls** is used to configure the HA cluster. Check the options in: [habootstrap-formula](https://github.com/krig/habootstrap-formula)


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
