sap_inst_directory:
  file.directory:
    - name: /root/sap_inst
    - user: root
    - mode: 755
    - makedirs: True
  mount.mounted:
    - name: /root/sap_inst
    - device: <update this value>
    - fstype: nfs4
    - mkmnt: True
    - persist: True
    - opts: tcp
