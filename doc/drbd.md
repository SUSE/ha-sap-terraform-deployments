# DRBD(Distributed Replicated Block Device)

Besides the default SAP Hana and HA cluster environment, the project can be tuned to deploy a NFS server base on DRBD device. This allows to create a high availability NFS share for Netweaver with the SAP Hana database.

The deployment will create 2 new virtual machines to host the NFS environment based on DRBD cluster. The DRBD cluster is managed by HA cluster to assure high availability of NFS backing device.

More details in the official [SAP on SUSE HA NFS](https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/sap/high-availability-guide-suse-nfs).

The deployment is performed using the [drbd-formula](https://github.com/SUSE/drbd-formula) and [habootstrap-formula](https://github.com/SUSE/habootstrap-formula).

**Disclaimer: Only available for libvirt by now.**

## Quickstart

In order to deploy a DRBD environment for NFS, some changes must be executed in terraform and salt folders. **By default DRBD cluster is not enabled.**

- In order to enable/disable the DRBD deployment update the value of `drbd_enabled` variable to true/false in the `terraform.tfvars` file, update the `drbd_count` if want to use more than 2 nodes.

- Choose the `drbd_shared_storage_type` to use different type of storage to *sbd* for HA cluster.

- Configure the `drbd_disk_size` for the size of attached DRBD backing device. Modify the `partitions` grain in [salt_provisioner.tf](../libvirt/modules/drbd_node/salt_provisioner.tf) for the layout of the disk for DRBD resouce.

- Modify the [drbd_cluster.j2](../salt/drbd_node/files/templates/drbd_cluster.j2) for the pacemaker resource configuration including *NFS* share mount options. To use customized template, need to adapt [formula.sls](../salt/drbd_node/formula.sls) and pillar file [cluster.sls](../salt/drbd_node/files/pillar/cluster.sls).

- Modify the content of [cluster.sls](../salt/drbd_node/files/pillar/cluster.sls) and [drbd.sls](../salt/drbd_node/files/pillar/drbd.sls). The unique mandatory changes are `promotion` and `resource` in the `drbd.sls` file. Change `res_template` if want to use customized template. These values must match with the environment(hostname, ip, ports, etc...), the current values are just an example.
