parted_drbd:
  pkg.installed:
  - name: parted
  - retry:
    attempts: 3
    interval: 15

mklabel_drbd:
  module.run:
    - partition.mklabel:
      - device: {{ grains['drbd_disk_device'] }}
      - label_type: gpt

mkpart_drbd:
  module.run:
    - partition.mkpart:
      - device: {{ grains['drbd_disk_device'] }}
      - part_type: primary
      - fs_type: ext3
      - start: 0%
      - end: 100%

partition_alignment_drbd:
  module.run:
    - partition.align_check:
      - device: {{ grains['drbd_disk_device'] }}
      - part_type: optimal
      - partition: 1
