# Saptune deployment configuration

You can tune your HANA or S/4HANA and NetWeaver nodes with saptune during the deployment phase.


In order to apply a saptune solution, you need to adapt the pillars
during deployment:

```
saptune_solution: 'HANA'
```

By default the pillars are configured to apply HANA for hana nodes and
NETWEAVER solution for NetWeavers.

For further information refer to the saphanaboostrap-formula or NetWeaver.
The code for the module is implemented in 
[SUSE/salt-shaptools repository🔗](https://github.com/SUSE/salt-shaptools).
