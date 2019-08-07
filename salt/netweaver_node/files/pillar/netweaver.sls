netweaver:
  virtual_addresses:
    192.168.135.2: {{ grains['name_prefix'] }}01
    192.168.135.3: {{ grains['name_prefix'] }}02
    192.168.135.4: sapha1as
    192.168.135.5: sapha1er
  swpm_media: d58.suse.de:/home/diegoakechi/ilya_nfs_backup/sap_inst_media
  sapmnt_inst_media: 10.162.32.134:/sapdata/HA1/
  swpm_folder: SWPM_10_SP26_6
  sapexe_folder: kernel_nw75_sar

  nodes:
    - host: {{ grains['name_prefix'] }}01
      virtual_host: sapha1as
      sid: HA1
      instance: 00
      root_user: root
      root_password: linux
      master_password: SuSE1234
      shared_disk_dev: /dev/vdc
      init_shared_disk: True
      sap_instance: ascs

    - host: {{ grains['name_prefix'] }}02
      virtual_host: sapha1er
      sid: HA1
      instance: 10
      root_user: root
      root_password: linux
      master_password: SuSE1234
      shared_disk_dev: /dev/vdc
      sap_instance: ers
