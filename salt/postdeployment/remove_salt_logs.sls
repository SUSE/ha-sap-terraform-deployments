# remove logfiles that could contain sensitive information
/var/log/salt-os-setup.log:
  file.absent
/var/log/salt-predeployment.log:
  file.absent
/var/log/salt-deployment.log:
  file.absent
/var/log/salt-postdeployment.log:
  file.absent
