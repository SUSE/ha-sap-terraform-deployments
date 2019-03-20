nfs-client:
  pkg.installed

sap_inst_directory:
  file.directory:
    - name: /root/sap_inst
    - user: root
    - mode: 755
    - makedirs: True
  {% if grains['provider'] == 'libvirt' %}
  mount.mounted:
    - name: /root/sap_inst
    - device: {{grains['sap_inst_media']}}
    - fstype: nfs
    - mkmnt: True
    - persist: True
    - opts: tcp
    - required:
      - nfs-client
  {% else %}
  mount.mounted:
    - name: {{grains['hana_inst_folder']}}
    - device: {{grains['hana_inst_master']}}
    - fstype: cifs
    - mkmnt: True
    - persist: True
    - opts: vers=3.0,username={{grains['storage_account_name']}},password={{grains['storage_account_key']}},dir_mode=0777,file_mode=0777,sec=ntlmssp
    - required:
      - nfs-client
  {% endif %}
