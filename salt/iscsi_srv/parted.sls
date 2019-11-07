mklabel:
  module.run:
    - partition.mklabel:
      - device: {{ grains['iscsidev'] }}
      - label_type: gpt

{% for id, data in grains['partitions'].items() %}
mkpart{{ id }}:
  module.run:
    - partition.mkpart:
      - device: {{ grains['iscsidev'] }}
      - part_type: primary
      - fs_type: ext2
      - start: {{ data['start'] }}
      - end: {{ data['end'] }}

partition_alignment_{{ id }}:
  module.run:
    - partition.align_check:
      - device: {{ grains['iscsidev'] }}
      - part_type: optimal
      - partition: {{ id }}
{% endfor %}
