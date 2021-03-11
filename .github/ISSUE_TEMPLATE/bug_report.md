---
name: Bug report
about: Bug report template
title: ''
labels: bug
assignees: arbulu89

---

**Used cloud platform**
Specify the used cloud platform (AWS, GCP, Azure, etc)

**Used SLES4SAP version**
Specify the used SLES4SAP version (SLES12SP4, SLES15SP2, etc)

**Used client machine OS**
Specify the used machine OS to execute the project (Windows, any Linux distro, macOS).
Even though terraform is multi-platform, some of the local actions are based in Linux distributions, so some operations might fail for this reason.

**Expected behaviour vs observed behaviour**
Describe with details what is the faced issue during the usage of the project, and what would be the expected result. If the error is just that `I cannot make the project work, it always fails` specify the next chapters information so we can understand in which point the project fails.

**How to reproduce**
Specify the step by step process to reproduce the issue. This usually would look like something like this:

1. Move to any of the cloud providers folder
2. Create the `terraform.tfvars` file based on `terraform.tfvars.example`
3. Run the next terraform commands:
  ```
  terraform init
  terraform plan
  terraform apply -auto-approve
  ```

The usage of the `provisioning_log_level = "info"` option in the `terraform.tfvars` file is interesting to get more information during the terraform commands execution. So it is suggested to run the deployment with this option to see what happens before opening any ticket.

**Used terraform.tfvars**
Paste here the used `terraform.tfvars` file content. If the file has any secret, change them by dummy information.

**Logs**
Upload the deployment logs to make the root cause finding easier. **The logs might have sensitive secrets exposed. Remove them before uploading anything here. Otherwise, contact @arbulu89 to send the logs privately**.

These is the list of the required logs (each of the deployed machines will have all of them):
- /var/log/salt-os-setup.log
- /var/log/salt-predeployment.log
- /var/log/salt-deployment.log
- /var/log/salt-result.log

Additional logs might be required to deepen the analysis on HANA or NETWEAVER installation. They will be asked specifically in case of need.
