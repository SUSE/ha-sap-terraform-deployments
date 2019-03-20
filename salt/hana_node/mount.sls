parted:
  pkg.installed

hana_partition:
  cmd.run:
    - name: /usr/sbin/parted -s {{grains['hana_disk_device']}} mklabel msdos && /usr/sbin/parted -s {{grains['hana_disk_device']}} mkpart primary ext2 1M 100% && sleep 1 && /sbin/mkfs.xfs {{grains['hana_disk_device']}}1
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
    - fstype: xfs
    - mkmnt: True
    - persist: True
    - opts:
      - defaults
    - require:
      - cmd: hana_partition
