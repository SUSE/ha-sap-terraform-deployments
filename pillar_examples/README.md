# Pillar examples

This folder stores pillar examples to use in the Salt provisioning.
To run an initial deployment without specific customization the usage of the pillar files stored in the `automatic` folder is recommended, as this files are customized with parameters coming from terraform execution. The pillar files stored there are able to deploy a basic functional set of clusters in all of the available cloud providers.

The usage of the pillar files is really simple. Basically, copy the content of the examples directories in the next locations.
- `pillar/hana` for HANA configuration.
- `pillar/drbd` for DRBD configuration.
- `pillar/netweaver` for NETWEAVER configuration.

The next commands can be used for that:

```
cp pillar_examples/automatic/hana/*.sls pillar/hana
cp pillar_examples/automatic/drbd/*.sls pillar/drbd
cp pillar_examples/automatic/netweaver/*.sls pillar/netweaver
```

Besides this option, the `terraform.tfvars` `pre_deployment` variable will execute these operations if it's enabled before the deployment.

**`pre_deployment` usage only works in clients using Linux**

For more advanced options, continue reading.

---
- [SAP HANA and HA cluster](#sap-hana-and-ha-cluster)
- [DRBD cluster](#drbd-cluster-for-nfs)
- [SAP NETWEAVER and HA cluster](#sap-netweaver-and-ha-cluster)

---
# Advanced pillar configuration

The salt execution formulas are implemented in different projects. You can find all of the pillar options in each of them.

- https://github.com/SUSE/saphanabootstrap-formula (HANA configuration)
- https://github.com/SUSE/habootstrap-formula (HA cluster configuration)
- https://github.com/SUSE/drbd-formula (DRBD configuration)
- https://github.com/SUSE/sapnwbootstrap-formula (NETWEAVER or S4/HANA configuration)


# Pillar encryption

Pillars are expected to contain private data such as user passwords required for the automated installation or other operations. Therefore, such pillar data need to be stored in an encrypted state, which can be decrypted during pillar compilation.

SaltStack GPG renderer provides a secure encryption/decryption of pillar data. The configuration of GPG keys and procedure for pillar encryption are desribed in the Saltstack documentation guide:

- [SaltStack pillar encryption](https://docs.saltstack.com/en/latest/topics/pillar/#pillar-encryption)

- [SALT GPG RENDERERS](https://docs.saltstack.com/en/latest/ref/renderers/all/salt.renderers.gpg.html)

**Note:**
- Only passwordless gpg keys are supported, and the already existing keys cannot be used.

- If a masterless approach is used (as in the current automated deployment) the gpg private key must be imported in all the nodes. This might require the copy/paste of the keys.
