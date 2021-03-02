nfs-client:
  pkg.installed:
  - retry:
     attempts: 3
     interval: 15

hana_inst_directory:
  file.directory:
    - name: {{ grains['hana_inst_folder'] }}
    - mode: "0755"
    - makedirs: True
  {% if grains['provider'] == 'libvirt' %}
  mount.mounted:
    - name: {{ grains['hana_inst_folder'] }}
    - device: {{ grains['hana_inst_master'] }}
    - fstype: nfs
    - mkmnt: True
    - persist: True
    - opts: tcp
    - required:
      - nfs-client
  {% else %}
  mount.mounted:
    - name: {{ grains['hana_inst_folder'] }}
    - device: {{ grains['hana_inst_master'] }}
    - fstype: cifs
    - mkmnt: True
    - persist: True
    - opts: vers=3.0,username={{ grains['storage_account_name'] }},password={{ grains['storage_account_key'] }},dir_mode=0777,file_mode=0777,sec=ntlmssp
    - required:
      - nfs-client
  {% endif %}
