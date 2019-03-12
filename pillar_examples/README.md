# Pillar examples
This folder stores pillar examples to use in the Salt provisioning.

Depending on the provider used to deploy SAP HANA and the HA cluster,
the required parameters are slightly different, even though most of them
match.

In order to use any of them, copy the content of each provider to:
salt/hana_node/files/pillar with the same file names.

All the information about how to tune the deployment is available in:
- https://github.com/SUSE/saphanabootstrap-formula (to manipulate the hana.sls file)
- https://github.com/SUSE/habootstrap-formula (to manipulate the cluster.sls file)

Finally, if instead of deploying SAP HANA and the cluster together, to only
deploy one of them update the salt/hana_node/files/salt/top.sls file only using
the desired componente and removing/commenting the other.
