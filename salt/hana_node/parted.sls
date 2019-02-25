parted:
  pkg.installed

mklabel:
  module.run:
    - name: partition.mklabel
    - device: {{ grains['hana_disk_device'] }}
    - label_type: msdos

mkpart1:
  module.run:
    - name: partition.mkpart
    - device: {{ grains['hana_disk_device'] }}
    - part_type: primary
    - start: 0
    - end: 100%

partition_alignment_1:
  module.run:
    - name: partition.align_check
    - device: {{ grains['hana_disk_device'] }}
    - part_type: optimal
    - partition: 1

format_hana_device:
  blockdev.formatted:
    - name: "{{ grains['hana_disk_device'] }}1"
    - fs_type: xfs

mount_hana_device:
  mount.mounted:
    - name: /hana
    - device: "{{ grains['hana_disk_device'] }}1"
    - fstype: xfs
    - opts: defaults
    - mkmnt: True
    - persist: True
