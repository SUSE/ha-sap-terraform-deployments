{% if grains['provider'] == 'libvirt' %}
mount_swpm:
  mount.mounted:
    - name: /netweaver_inst_media
    - device: {{ grains['netweaver_inst_media'] }}
    - fstype: nfs
    - mkmnt: True
    - persist: True
    - opts:
      - defaults

{% elif grains['provider'] == 'azure' %}
mount_swpm:
  mount.mounted:
    - name: /netweaver_inst_media
    - device: {{ grains['storage_account_path'] }}
    - fstype: cifs
    - mkmnt: True
    - persist: True
    - opts:
      - vers=3.0,username={{ grains['storage_account_name'] }},password={{ grains['storage_account_key'] }},dir_mode=0777,file_mode=0777,sec=ntlmssp
{% endif %}
