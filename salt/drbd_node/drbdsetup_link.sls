# Workaround to make drbdsetup available among different SLE versions
/usr/sbin/drbdsetup:
  file.symlink:
    - target: /sbin/drbdsetup
