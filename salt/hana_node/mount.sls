{% if grains['provider'] == 'libvirt' %}
{% set fs_type = 'ext4' %}
{% else %}
{% set fs_type = 'xfs' %}
{% endif %}


parted:
  pkg.installed

hana_partition:
  cmd.run:
    - name: /usr/sbin/parted -s {{grains['hana_disk_device']}} mklabel msdos && /usr/sbin/parted -s {{grains['hana_disk_device']}} mkpart primary ext2 1M 100% && sleep 1 && /sbin/mkfs.{{ fs_type }} {{grains['hana_disk_device']}}1
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
    - fstype: {{ fs_type }}
    - mkmnt: True
    - persist: True
    - opts:
      - defaults
    - require:
      - cmd: hana_partition
