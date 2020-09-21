# QA usage
You may have noticed the variable **`qa_mode`**, this project is also used for Quality Assurance testing.

## Specific QA variables
**`qa_mode`** is used to inform the deployment that we are doing QA. Don't forget to set `qa_mode` to true in your `terraform.tfvars` file. By default, `qa_mode` is set to false.

Below is the expected behavior:

- disables extra packages installation (sap, ha pattern etc).
- disables first registration to install salt-minion, we consider that images are delivered with
 salt-minion included.
- disables salt color output (better for debugging in automated scenario)

<br>

**`hwcct`**: If set to true, it executes HANA Hardware Configuration Check Tool to bench filesystems. It's a very long test (about 2 hours), results will be both in /root/hwcct_out and in the global log file /var/log/salt-result.log. 
By default, `hwcct` is set to false. Variable **`qa_mode` must be set to true**.
