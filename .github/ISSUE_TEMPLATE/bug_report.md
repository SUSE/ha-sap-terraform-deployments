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

**Describe the bug**
A clear and concise description of what the bug is.

**Used terraform.tfvars**
Paste here the used `terraform.tfvars` file. If the files has any secret, change them by dummy information.

**Logs**
Upload the deployment logs to make the root cause finding easier. **The logs might have sensitive secrets exposed. Remove them before uploading anything here. Otherwise, contact @arbulu89 to send the logs in privately**.

These is the list of the required logs:
- /var/log/salt-os-setup.log
- /var/log/salt-predeployment.log
- /var/log/salt-deployment.log
- /var/log/salt-result.log

Additional logs might be required to deepen the analysis on HANA or NETWEAVER installation. They will be asked specifically in case of need.
