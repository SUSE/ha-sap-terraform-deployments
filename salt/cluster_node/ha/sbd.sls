# This state is executed at the end of iscsi_initiator.sls state
{% set sbd_disk_id_pattern = '/^\[[0-9]\:[0-9]\:[0-9]\:'~grains['sbd_lun_index']~'\].*/' %}
{% set sbd_disk_device = salt['cmd.run']('lsscsi -i | grep "LIO-ORG" | awk "'~sbd_disk_id_pattern~'{print \$NF }"', python_shell=true) %}
{% set sbd_disk_device = '/dev/disk/by-id/scsi-'~sbd_disk_device %}

sbd_disk_device:
  grains.present:
    - name: sbd_disk_device
    - value: {{ sbd_disk_device }}
