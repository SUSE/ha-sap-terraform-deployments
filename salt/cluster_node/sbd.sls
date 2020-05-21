# This state is executed at the end of iscsi_initiator.sls state
{% set sbd_disk_device = salt['cmd.run']('lsscsi | grep "LIO-ORG" | awk "{ if (NR=='~grains['sbd_disk_index']~') print \$NF }"', python_shell=true) %}

sbd_disk_device:
  grains.present:
    - name: sbd_disk_device
    - value: {{ sbd_disk_device }}
