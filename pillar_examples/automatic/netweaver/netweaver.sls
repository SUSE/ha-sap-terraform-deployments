{%- set iprange = '.'.join(grains['host_ips'][0].split('.')[0:-1]) %}

{%- if grains['provider'] == 'libvirt' %}
{%- set virtual_host_interface = 'eth1' %}
{%- else %}
{%- set virtual_host_interface = 'eth0' %}
{%- endif %}
{%- if grains['provider'] in ['gcp', 'aws'] %}
{%- set virtual_host_mask = 32 %}
{%- else %}
{%- set virtual_host_mask = 24 %}
{%- endif %}

netweaver:
  virtual_addresses:
    {{ grains['virtual_host_ips'][0] }}: sapha1as
    {{ grains['virtual_host_ips'][1] }}: sapha1er
    {{ grains['virtual_host_ips'][2] }}: sapha1pas
    {{ grains['virtual_host_ips'][3] }}: sapha1aas
  sidadm_user:
    uid: 2001
    gid: 2002
  sid_adm_password: SuSE1234
  sap_adm_password: SuSE1234
  master_password: SuSE1234
  sapmnt_inst_media: "{{ grains['netweaver_nfs_share'] }}"
  {%- if grains.get('netweaver_swpm_folder', False) %}
  swpm_folder: /sapmedia/NW/{{ grains['netweaver_swpm_folder'] }}
  {%- endif %}
  {%- if grains.get('netweaver_sapcar_exe', False) and grains.get('netweaver_swpm_sar', False) %}
  sapcar_exe_file: /sapmedia/NW/{{ grains['netweaver_sapcar_exe'] }}
  swpm_sar_file: /sapmedia/NW/{{ grains['netweaver_swpm_sar'] }}
  {%- endif %}
  {%- if grains.get('netweaver_swpm_extract_dir', False) %}
  swpm_extract_dir: {{ grains['netweaver_swpm_extract_dir'] }}
  {%- endif %}
  sapexe_folder: /sapmedia/NW/{{ grains['netweaver_sapexe_folder'] }}
  additional_dvds: {%- if not grains['netweaver_additional_dvds'] %} []
  {%- else %}
    {%- for dvd in grains['netweaver_additional_dvds'] %}
    - /sapmedia/NW/{{ dvd }}
    {%- endfor %}
  {%- endif %}

  # apply by default the netweaver solution
  saptune_solution: 'NETWEAVER'

  # enable exporter if monitoring enabled
{%- if grains.get('monitoring_enabled', False) %}
  sap_host_exporter:
    enabled: true
{%- endif %}

  hana:
    host: {{ grains['hana_ip'] }}
    sid: PRD
    instance: '00'
    password: YourPassword1234

  schema:
    name: SAPABAP1
    password: SuSE1234

  product_id: {{ grains['netweaver_product_id'] }}

{%- if grains['provider'] == 'aws' %}
  nfs_options: rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2
{%- endif %}

  nodes:
    - host: {{ grains['name_prefix'] }}01
      virtual_host: sapha1as
      virtual_host_interface: {{ virtual_host_interface }}
      virtual_host_mask: {{ virtual_host_mask }}
      sid: HA1
      instance: {{ grains['ascs_instance_number'] }}
      root_user: root
      root_password: linux
      {%- if grains['provider'] == 'libvirt' %}
      shared_disk_dev: /dev/vdb
      init_shared_disk: True
      {%- else %}
      shared_disk_dev: {{ grains['netweaver_nfs_share'] }}/ASCS
      {%- endif %}
      sap_instance: ascs

    - host: {{ grains['name_prefix'] }}02
      virtual_host: sapha1er
      virtual_host_interface: {{ virtual_host_interface }}
      virtual_host_mask: {{ virtual_host_mask }}
      sid: HA1
      instance: {{ grains['ers_instance_number'] }}
      root_user: root
      root_password: linux
      {%- if grains['provider'] == 'libvirt' %}
      shared_disk_dev: /dev/vdb
      {%- else %}
      shared_disk_dev: {{ grains['netweaver_nfs_share'] }}/ERS
      {%- endif %}
      sap_instance: ers

    - host: {{ grains['name_prefix'] }}03
      virtual_host: sapha1pas
      virtual_host_interface: {{ virtual_host_interface }}
      virtual_host_mask: {{ virtual_host_mask }}
      sid: HA1
      instance: '00' # Not used
      root_user: root
      root_password: linux
      sap_instance: db

    - host: {{ grains['name_prefix'] }}03
      virtual_host: sapha1pas
      virtual_host_interface: {{ virtual_host_interface }}
      virtual_host_mask: {{ virtual_host_mask }}
      ascs_virtual_host: sapha1as
      sid: HA1
      instance: {{ grains['pas_instance_number'] }}
      root_user: root
      root_password: linux
      sap_instance: pas
      # Add for S4/HANA
      #extra_parameters:
      #  NW_liveCache.useLiveCache: "false"

    - host: {{ grains['name_prefix'] }}04
      virtual_host: sapha1aas
      virtual_host_interface: {{ virtual_host_interface }}
      virtual_host_mask: {{ virtual_host_mask }}
      sid: HA1
      instance: {{ grains['aas_instance_number'] }}
      root_user: root
      root_password: linux
      sap_instance: aas
      # Add for S4/HANA
      #attempts: 500
