# SBD fencing mechanism

SBD (Storage based death) is a fencing mechanism to halt nodes that are in inconsistent state. In order to be used all the clustered nodes must have a shared disk.

Find more information in:
- https://wiki.clusterlabs.org/wiki/Using_SBD_with_Pacemaker
- http://www.linux-ha.org/wiki/SBD_Fencing

The next options are available to use SBD as our cluster fencing mechanism.

## ISCSI server

Use a shared disk served by an ISCSI server. This is a quite standard option if the clusters hosted in the cloud, as shared disks are not commonly available. To use this option, an ISCSI server must be created (or use an already existing one). The project gives the option to create a new virtual machine to host this service. For that we need to use the next variables:
- Set `sbd_storage_type` to `iscsi`
- Enable at least one cluster that will use SBD setting the option `*_cluster_sbd_enabled` to `true`
- ISCSI server configuration has some advanced configuration options. Check the terraform template examples and the available variables for that.

## Shared disk

Use a shared disk attached to all clustered nodes. To use this option:
- Set `sbd_storage_type` to `shared-disk`

## Usage guide

The usage of SBD using ISCSI is mandatory by now in Azure, as it doesn't provide any other fencing mechanism. AWS and GCP have native fencing mechanisms, so SBD usage is optional.
A deployment done in Libvirt can use ISCSI or shared disk, both are available, but one of them must be provided.
