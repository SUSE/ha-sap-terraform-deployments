# Fencing mechanism

The fencing mechanism is used to halt nodes that are in inconsistent state. The fencing is required to have a correctly working cluster. Without it, the cluster cannot stop inconsistent nodes making the whole concept of High Availability impossible.

The project provides the next fencing options:
- SBD
- Cloud native fencing (only available for AWS and GCP by now)

Usually the cloud native fence mechanism is recommended as it simpler and less expensive.

## SBD

SBD (Storage Based Death) uses a shared disk among the nodes to halt the nodes.

Find more information in:
- https://wiki.clusterlabs.org/wiki/Using_SBD_with_Pacemaker
- http://www.linux-ha.org/wiki/SBD_Fencing

The next options are available to use SBD as the cluster fencing mechanism.

### ISCSI server

Use a shared disk served by an ISCSI server. This is a quite standard option if the clusters are hosted in the cloud, as shared disks are not commonly available. To use this option, an ISCSI server must be created (or use an already existing one). The project gives the option to create a new virtual machine to host this service. For that we need to use the next variables:
- Set `sbd_storage_type` to `iscsi`
- Enable at least one cluster that will use SBD setting the option `*_cluster_fencing_mechanism` to `sbd`
- ISCSI server configuration has some advanced configuration options. Check the terraform template examples and the available variables for that.

### Shared disk

Use a shared disk attached to all clustered nodes. **This option is only available for libvirt**. To use this option:
- Set `sbd_storage_type` to `shared-disk`
- Enable at least one cluster that will use SBD setting the option `*_cluster_fencing_mechanism` to `sbd`

## Cloud native fencing

The cloud native fencing mechanism is based in capabilities of the cloud providers to halt the virtual machines using their own APIs. This means that there is not any need to have additional machines or resources, making them simpler and less expensive. **This option is only available for AWS and GCP by now.**

To use this option:
- Set `*_cluster_fencing_mechanism` to `native` to the clusters that have to use this mechanism.
