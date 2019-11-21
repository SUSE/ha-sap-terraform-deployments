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
