# Pillar examples
This folder stores pillar examples to use in the Salt provisioning.

Depending on the provider used to deploy SAP HANA and the HA cluster,
the required parameters are slightly different, even though most of them
match.

Two possibilities here:

  - For a preconfigured environment, you can use pillar files which are in [automatic directory](./automatic).

      **Could be used for testing purpose and not for production as they have default settings.**

      From git top-level folder, copy files:

      `cp pillar_examples/automatic/hana/*.sls salt/hana_node/files/pillar/`

  - For a customize and production environment, you must use pillar files which are in your choosen [provider directory](../pillar_examples) (AWS, Azure, GCP, Libvirt).

      From git top-level folder, copy files:

      `cp pillar_examples/$PROVIDER/*.sls salt/hana_node/files/pillar`

      Please, **pay attention:** different from the previous case (preconfigured environment or automatic), the pillars must be customized, otherwise deployment will fail.

All the information about how to tune the deployment is available in:
- https://github.com/SUSE/saphanabootstrap-formula (to manipulate the hana.sls file)
- https://github.com/SUSE/habootstrap-formula (to manipulate the cluster.sls file)


### Libvirt specifics

One thing is different with Libvirt provider, in pillar's directory, you will find two directories about HANA profiles (cost_optimized and performance_optimized).
Choose one according to your needs.

Finally, if instead of deploying SAP HANA and the cluster together, to only
deploy one of them update the salt/hana_node/files/salt/top.sls file only using
the desired component and removing/commenting the other.


# DRBD automatic pillar
For a preconfigured environment, you can use pillar files which are in [DRBD automatic directory](./automatic/drbd)

**Could be used for testing purpose and not for production as they have default settings.**

From git top-level folder, copy files:

`cp pillar_examples/automatic/drbd/*.sls salt/drbd_node/files/pillar/`

All the information about how to tune the deployment is available in:
- https://github.com/SUSE/drbd-formula (to manipulate the drbd.sls file)
- https://github.com/SUSE/habootstrap-formula (to manipulate the cluster.sls file)

