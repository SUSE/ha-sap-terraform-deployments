# Troubleshooting

The goal of this guide is to provide some useful entrypoints for debug.


Feel free to open an issue with these logs, and/or analyze them accordingly.


# Salt usefull logs

- `/var/log/salt-os-setup.log`:  initial OS setup registering the machines to SCC, updating the system, etc.
- `/var/log/salt-predeployment.log`:  before executing formula states, execute the saltstack file contained in the repo of ha-sap-terraform-deployments.
- `/var/log/salt-deployment.log`: this is the log file where the formulas salt execution is logged. (salt-formulas are not part of the github deployments project).


# Netweaver debugging

- `/tmp/swpm_unnattended/sapinst.log` is the best first entrypoint to look at when debugging netweaver failures.


# Misc

When opening/issues, provide Which SLE version, which provider, and the logs (described before).
