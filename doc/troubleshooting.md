# Troubleshooting

The goal of this guide is to provide some useful entry points for debug.
Feel free to open an issue with these logs, and/or analyze them accordingly.

# Debugging

The variable `provisioning_log_level` variable can be used to change the logging verbosity/level (being `error` by default). Change to `info` or `debug` to get more hints about what's going on.
Find here the log level options for salt: https://docs.saltstack.com/en/latest/ref/configuration/logging/index.html


# Salt useful logs

Besides the `terraform` execution output, more logs are stored within the created machines in the next logging files.

- `/var/log/salt-result.log`: Summarized result of the salt execution processes.
- `/var/log/salt-os-setup.log`:  initial OS setup registering the machines to SCC, updating the system, etc.
- `/var/log/salt-predeployment.log`:  before executing formula states, execute the saltstack file contained in the repository of ha-sap-terraform-deployments.
- `/var/log/salt-deployment.log`: this is the log file where the formulas salt execution is logged. (salt-formulas are not part of the github deployments project).


# Netweaver debugging

- `/tmp/swpm_unnattended/sapinst.log` is the best first entry point to look at when debugging netweaver failures.


# Misc

When opening/issues, provide Which SLE version, which provider, and the logs (described before).
