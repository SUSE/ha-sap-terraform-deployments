# This state is executed at the end of iscsi_initiator.sls state. /etc/iscsi is already populated at this point.
# Use "by-path+IP+IQN" as these are persistent even after an iscsi server reboot.
# The wwn cannot be used as it will change after an iscsi server reboot.
{% set iscsi_connection = salt['cmd.run']('ls -1 /etc/iscsi/nodes | head -1', python_shell=true) %}
{% set sbd_disk_device = '/dev/disk/by-path/ip-'~grains['iscsi_srv_ip']~':3260-iscsi-'~iscsi_connection~'-lun-'~grains['sbd_lun_index'] %}

sbd_disk_device:
  grains.present:
    - name: sbd_disk_device
    - value: {{ sbd_disk_device }}
