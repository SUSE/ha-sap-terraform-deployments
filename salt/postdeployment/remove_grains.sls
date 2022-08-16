# remove grains file as it might include sensitive information
/etc/salt/grains:
  file.absent
