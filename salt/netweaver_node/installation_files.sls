{% if grains['provider'] == 'libvirt' %}
nfs-client:
  pkg.installed:
    - retry:
        attempts: 3
        interval: 15

mount_swpm:
  mount.mounted:
    - name: /netweaver_inst_media
    - device: {{ grains['netweaver_inst_media'] }}
    - fstype: nfs
    - mkmnt: True
    - persist: True
    - opts:
      - defaults
{% endif %}
