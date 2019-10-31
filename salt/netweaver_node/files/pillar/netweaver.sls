{% set iprange = ".".join(grains['host_ips'][0].split('.')[0:-1]) %}

netweaver:
  virtual_addresses:
    {{ iprange }}.10: {{ grains['name_prefix'] }}01
    {{ iprange }}.11: {{ grains['name_prefix'] }}02
    {{ iprange }}.12: {{ grains['name_prefix'] }}03
    {{ iprange }}.13: {{ grains['name_prefix'] }}04
    {{ iprange }}.15: sapha1as
    {{ iprange }}.16: sapha1er
    {{ iprange }}.17: sapha1db
    {{ iprange }}.18: sapha1pas
    {{ iprange }}.19: sapha1aas
  swpm_media: {{ grains['sap_inst_media'] }}
  sapmnt_inst_media: {{ grains['netweaver_nfs_share'] }}
  swpm_folder: SWPM_10_SP26_6
  sapexe_folder: kernel_nw75_sar
  additional_dvds:
    - '51050829_3' # NW Export folder
    - '51053787' # HANA HDB Client folder

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
      instance: '00'
      root_user: root
      root_password: linux
      master_password: SuSE1234
      shared_disk_dev: /dev/vdb
      init_shared_disk: True
      sap_instance: ascs

    - host: {{ grains['name_prefix'] }}02
      virtual_host: sapha1er
      sid: HA1
      instance: '10'
      root_user: root
      root_password: linux
      master_password: SuSE1234
      shared_disk_dev: /dev/vdb
      sap_instance: ers

    - host: {{ grains['name_prefix'] }}03
      virtual_host: sapha1db
      sid: HA1
      instance: '00'
      root_user: root
      root_password: linux
      master_password: SuSE1234
      sap_instance: db

    - host: {{ grains['name_prefix'] }}03
      virtual_host: sapha1pas
      ascs_virtual_host: sapha1as
      sid: HA1
      instance: '01'
      root_user: root
      root_password: linux
      master_password: SuSE1234
      sap_instance: pas

    - host: {{ grains['name_prefix'] }}04
      virtual_host: sapha1aas
      sid: HA1
      instance: '02'
      root_user: root
      root_password: linux
      master_password: SuSE1234
      sap_instance: aas
