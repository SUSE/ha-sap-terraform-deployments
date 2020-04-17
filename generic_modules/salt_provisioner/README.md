# Salt provisioner

This terraform module aims to implement the salt provisioning operations.

The provisioning has 2 different modes.

1. Normal execution: This execution will keep the terraform process up and running until the end of the whole salt execution (positive or negative outcome). It will print the logs in the console.

2. Background execution: The terraform project will run the salt operations in background finishing the current process with the terraform return code. This mode can be helpful in scenarios where the network connection is not good and the connection to the machines created by terrafrom can be dropped. **This option doesn't run the `reboot` action after the updates.**
