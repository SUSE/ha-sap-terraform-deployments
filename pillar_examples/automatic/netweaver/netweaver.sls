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
{%- set sid_lower = grains['netweaver_sid'].lower() %}
{%- set sid_upper = grains['netweaver_sid'].upper() %}

netweaver:
  {%- set app_start_index = 2 if grains['ha_enabled'] else 1 %}
  {%- set app_server_count = grains['app_server_count']|default(2) %}
  virtual_addresses:
    {{ grains['virtual_host_ips'][0] }}: sap{{ sid_lower }}as
    {%- if grains['ha_enabled'] %}
    {{ grains['virtual_host_ips'][1] }}: sap{{ sid_lower }}er
    {%- endif %}
    {%- if app_server_count > 0 %}
    {{ grains['virtual_host_ips'][app_start_index] }}: sap{{ sid_lower }}pas
    {%- for index in range(app_server_count-1) %}
    {{ grains['virtual_host_ips'][loop.index+app_start_index] }}: sap{{ sid_lower }}aas{{ loop.index }}
    {%- endfor %}
    {%- endif %}

  sidadm_user:
    uid: 2001
    gid: 2002
  sid_adm_password: SuSE1234
  sap_adm_password: SuSE1234
  master_password: SuSE1234
  sapmnt_inst_media: "{{ grains['netweaver_nfs_share'] }}"
  {%- if grains.get('netweaver_swpm_folder', False) %}
  swpm_folder: {{ grains['netweaver_inst_folder'] }}/{{ grains['netweaver_swpm_folder'] }}
  {%- endif %}
  {%- if grains.get('netweaver_sapcar_exe', False) and grains.get('netweaver_swpm_sar', False) %}
  sapcar_exe_file: {{ grains['netweaver_inst_folder'] }}/{{ grains['netweaver_sapcar_exe'] }}
  swpm_sar_file: {{ grains['netweaver_inst_folder'] }}/{{ grains['netweaver_swpm_sar'] }}
  {%- endif %}
  {%- if grains.get('netweaver_extract_dir', False) %}
  nw_extract_dir: {{ grains['netweaver_extract_dir'] }}
  {%- endif %}
  sapexe_folder: {{ grains['netweaver_inst_folder'] }}/{{ grains['netweaver_sapexe_folder'] }}
  additional_dvds: {%- if not grains['netweaver_additional_dvds'] %} []
  {%- else %}
    {%- for dvd in grains['netweaver_additional_dvds'] %}
    - {{ grains['netweaver_inst_folder'] }}/{{ dvd }}
    {%- endfor %}
  {%- endif %}

  # apply by default the netweaver solution
  saptune_solution: 'NETWEAVER'

  monitoring_enabled: {{ grains['monitoring_enabled']|default(False) }}

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

  ha_enabled: {{ grains['ha_enabled'] }}

  nodes:
    - host: {{ grains['name_prefix'] }}01
      virtual_host: sap{{ sid_lower }}as
      virtual_host_interface: {{ virtual_host_interface }}
      virtual_host_mask: {{ virtual_host_mask }}
      sid: {{ sid_upper }}
      instance: {{ '{:0>2}'.format(grains['ascs_instance_number']) }}
      root_user: root
      root_password: linux
      {%- if grains['ha_enabled'] and grains['provider'] == 'libvirt' %}
      shared_disk_dev: /dev/vdb
      init_shared_disk: True
      {%- elif grains['ha_enabled'] %}
      shared_disk_dev: {{ grains['netweaver_nfs_share'] }}/ASCS
      {%- endif %}
      sap_instance: ascs

    {% if grains['ha_enabled'] %}
    - host: {{ grains['name_prefix'] }}02
      virtual_host: sap{{ sid_lower }}er
      virtual_host_interface: {{ virtual_host_interface }}
      virtual_host_mask: {{ virtual_host_mask }}
      sid: {{ sid_upper }}
      instance: {{ '{:0>2}'.format(grains['ers_instance_number']) }}
      root_user: root
      root_password: linux
      {%- if grains['provider'] == 'libvirt' %}
      shared_disk_dev: /dev/vdb
      {%- else %}
      shared_disk_dev: {{ grains['netweaver_nfs_share'] }}/ERS
      {%- endif %}
      sap_instance: ers
    {% endif %}

    {% if app_server_count > 0 %}
    - host: {{ grains['name_prefix'] }}0{{ app_start_index+1 }}
      virtual_host: sap{{ sid_lower }}pas
      virtual_host_interface: {{ virtual_host_interface }}
      virtual_host_mask: {{ virtual_host_mask }}
      sid: {{ sid_upper }}
      instance: '00' # Not used
      root_user: root
      root_password: linux
      sap_instance: db

    - host: {{ grains['name_prefix'] }}0{{ app_start_index+1 }}
      virtual_host: sap{{ sid_lower }}pas
      virtual_host_interface: {{ virtual_host_interface }}
      virtual_host_mask: {{ virtual_host_mask }}
      ascs_virtual_host: sap{{ sid_lower }}as
      sid: {{ sid_upper }}
      instance: {{ '{:0>2}'.format(grains['pas_instance_number']) }}
      root_user: root
      root_password: linux
      sap_instance: pas
      # Add for S4/HANA
      #extra_parameters:
      #  NW_liveCache.useLiveCache: "false"

    {%- for index in range(app_server_count-1) %}
    - host: {{ grains['name_prefix'] }}0{{ app_start_index+1+loop.index }}
      virtual_host: sap{{ sid_lower }}aas{{ loop.index }}
      virtual_host_interface: {{ virtual_host_interface }}
      virtual_host_mask: {{ virtual_host_mask }}
      sid: {{ sid_upper }}
      instance: {{ '{:0>2}'.format(grains['pas_instance_number']+loop.index) }}
      root_user: root
      root_password: linux
      sap_instance: aas
      # Add for S4/HANA
      #attempts: 500
    {% endfor %}
    {% endif %}
