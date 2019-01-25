nfs-client:
  pkg.installed

sap_inst_directory:
  file.directory:
    - name: /root/sap_inst
    - user: root
    - mode: 755
    - makedirs: True
  mount.mounted:
    - name: /root/sap_inst
    - device: {{grains['sap_inst_media']}}
    - fstype: nfs
    - mkmnt: True
    - persist: True
    - opts: tcp
    - required:
      - nfs-client
