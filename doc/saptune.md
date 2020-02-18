# Saptune deployment configuration

You can tune your hana or netweaver nodes with saptune during the deployment phase.

Currently we support following features:

- 1) apply a saptune solution during deployement


1) Apply a saptune solution during deployement:

In order to apply a saptune solution, you need to adapt the pillars:

```
saptune_solution: 'HANA'
```

By default the pillars are configured to apply HANA for hana nodes and NETWEAVER solution for netweavers.

For further information refer to the saphanaboostrap-formula or netweaver.
The code for the module is implemented in https://github.com/SUSE/salt-shaptools
