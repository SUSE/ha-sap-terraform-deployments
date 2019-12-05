{% set iprange = ".".join(grains['host_ips'][0].split('.')[0:-1]) %}

netweaver:
  virtual_addresses:
    {{ grains['host_ips'][0] }}: {{ grains['name_prefix'] }}01
    {{ grains['host_ips'][1] }}: {{ grains['name_prefix'] }}02
    {{ grains['host_ips'][2] }}: {{ grains['name_prefix'] }}03
    {{ grains['host_ips'][3] }}: {{ grains['name_prefix'] }}04
    {{ grains['virtual_ips'][0] }}: sapha1as
    {{ grains['virtual_ips'][1] }}: sapha1er
    {{ grains['virtual_ips'][2] }}: sapha1pas
    {{ grains['virtual_ips'][3] }}: sapha1aas
  sidadm_user:
    uid: 1001
    gid: 1002
  sapmnt_inst_media: {{ grains['netweaver_nfs_share'] }}
  swpm_folder: /netweaver_inst_media/SWPM_10_SP26_6
  sapexe_folder: /netweaver_inst_media/kernel_nw75_sar
  additional_dvds:
    - /netweaver_inst_media/51050829_3 # NW Export folder
    - /netweaver_inst_media/51053787 # HANA HDB Client folder

  hana:
    host: {{ iprange }}.200
    sid: PRD
    instance: '00'
    password: YourPassword1234

  schema:
    name: SAPABAP1
    password: SuSE1234

  nodes:
    - host: {{ grains['name_prefix'] }}01
      virtual_host: sapha1as
      sid: HA1
      instance: {{ grains['ascs_instance_number'] }}
      root_user: root
      root_password: linux
      master_password: SuSE1234
      shared_disk_dev: /dev/sdc
      init_shared_disk: True
      sap_instance: ascs

    - host: {{ grains['name_prefix'] }}02
      virtual_host: sapha1er
      sid: HA1
      instance: {{ grains['ers_instance_number'] }}
      root_user: root
      root_password: linux
      master_password: SuSE1234
      shared_disk_dev: /dev/sdc
      init_shared_disk: True
      sap_instance: ers

    - host: {{ grains['name_prefix'] }}03
      virtual_host: sapha1pas
      sid: HA1
      instance: '00' # Not used
      root_user: root
      root_password: linux
      master_password: SuSE1234
      sap_instance: db

    - host: {{ grains['name_prefix'] }}03
      virtual_host: sapha1pas
      ascs_virtual_host: sapha1as
      sid: HA1
      instance: {{ grains['pas_instance_number'] }}
      root_user: root
      root_password: linux
      master_password: SuSE1234
      sap_instance: pas

    - host: {{ grains['name_prefix'] }}04
      virtual_host: sapha1aas
      sid: HA1
      instance: {{ grains['aas_instance_number'] }}
      root_user: root
      root_password: linux
      master_password: SuSE1234
      sap_instance: aas
