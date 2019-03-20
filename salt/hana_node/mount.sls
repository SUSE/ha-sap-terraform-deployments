{% if grains['provider'] == 'libvirt' %}
parted:
  pkg.installed

hana_partition:
  cmd.run:
    - name: /usr/sbin/parted -s {{grains['hana_disk_device']}} mklabel msdos && /usr/sbin/parted -s {{grains['hana_disk_device']}} mkpart primary ext2 1M 100% && sleep 1 && /sbin/mkfs.ext4 {{grains['hana_disk_device']}}1
    - unless: ls {{grains['hana_disk_device']}}1
    - require:
      - pkg: parted

hana_directory:
  file.directory:
    - name: /hana
    - user: root
    - mode: 755
    - makedirs: True
  mount.mounted:
    - name: /hana
    - device: {{grains['hana_disk_device']}}1
    - fstype: ext4
    - mkmnt: True
    - persist: True
    - opts:
      - defaults
    - require:
      - cmd: hana_partition

{% else %}

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
    - fs_type: ext2
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

{% endif %}
