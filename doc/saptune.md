# Saptune deployment configuration

You can tune your hana or S/4HANA and NetWeaver nodes with saptune during the deployment phase.

Currently we support following features:

- 1) apply a saptune solution during deployment


1) Apply a saptune solution during deployment:

In order to apply a saptune solution, you need to adapt the pillars:

```
saptune_solution: 'HANA'
```

By default the pillars are configured to apply HANA for hana nodes and NETWEAVER solution for NetWeavers.

For further information refer to the saphanaboostrap-formula or NetWeaver.
The code for the module is implemented in https://github.com/SUSE/salt-shaptools
