# ephemeral devices will be automatically mounted on openstack
# syncing the drbd device will fail in this case
{% if grains['provider'] == 'openstack' %}
not_in_fstab:
  mount.fstab_absent:
    - name: {{ grains['drbd_disk_device'] }}
    - fs_file: /mnt

not_mounted:
  mount.unmounted:
    - name: /mnt
    - device: {{ grains['drbd_disk_device'] }}
{% endif %}

mklabel_drbd:
  module.run:
    - partition.mklabel:
      - device: {{ grains['drbd_disk_device'] }}
      - label_type: gpt

{% for id, data in grains['partitions'].items() %}
mkpart_{{ id }}:
  module.run:
    - partition.mkpart:
      - device: {{ grains['drbd_disk_device'] }}
      - part_type: primary
      - fs_type: ext3
      - start: {{ data['start'] }}
      - end: {{ data['end'] }}

partition_alignment_{{ id }}:
  module.run:
    - partition.align_check:
      - device: {{ grains['drbd_disk_device'] }}
      - part_type: optimal
      - partition: {{ id }}
{% endfor %}
