parted:
  pkg.installed

hana_partition:
  cmd.run:
    - name: /usr/sbin/parted -s /dev/{{grains['hana_disk_device']}} mklabel msdos && /usr/sbin/parted -s /dev/{{grains['hana_disk_device']}} mkpart primary ext2 1M 100% && sleep 1 && /sbin/mkfs.ext4 /dev/{{grains['hana_disk_device']}}1
    - unless: ls /dev/{{grains['hana_disk_device']}}1
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
    - device: /dev/{{grains['hana_disk_device']}}1
    - fstype: ext4
    - mkmnt: True
    - persist: True
    - opts:
      - defaults
    - require:
      - cmd: hana_partition
