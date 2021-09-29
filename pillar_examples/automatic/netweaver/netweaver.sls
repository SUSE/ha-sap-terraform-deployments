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
{%- set hana_sid_upper = grains['hana_sid'].upper() %}
{%- set hana_instance_number = '{:0>2}'.format(grains['hana_instance_number']) %}
{%- set product_id_header = grains['netweaver_product_id'].split(".")[0] %}

netweaver:
  {%- set app_server_count = grains['app_server_count']|default(2) %}
  {%- if not grains['ha_enabled'] %}
  {%- set app_start_index = [app_server_count, 1]|min %}
  {%- elif app_server_count == 0 %}
  {%- set app_start_index = 0 %}
  {%- else %}
  {%- set app_start_index = 2 %}
  {%- endif %}
  virtual_addresses:
    {{ grains['virtual_host_ips'][0] }}: sap{{ sid_lower }}as
    {%- if grains['ha_enabled'] %}
    {{ grains['virtual_host_ips'][1] }}: sap{{ sid_lower }}er
    {{ grains['virtual_host_ips'][2] }}: sap{{ sid_lower }}pas
    {%- else %}
    {{ grains['virtual_host_ips'][1] }}: sap{{ sid_lower }}pas
    {%- endif %}
    {%- for index in range(app_server_count-1) %}
    {{ grains['virtual_host_ips'][loop.index+app_start_index] }}: sap{{ sid_lower }}aas{{ loop.index }}
    {%- endfor %}

  sidadm_user:
    uid: 2001
    gid: 2002
  sid_adm_password: {{ grains['netweaver_master_password'] }}
  sap_adm_password: {{ grains['netweaver_master_password'] }}
  master_password: {{ grains['netweaver_master_password'] }}
  {%- if grains['provider'] == 'azure' and grains['netweaver_shared_storage_type'] == 'anf' %}
  sapmnt_inst_media: "{{ grains['anf_mount_ip']['sapmnt'][0] }}:/netweaver-sapmnt"
  {%- else %}
  sapmnt_inst_media: "{{ grains['netweaver_nfs_share'] }}"
  {%- endif %}
  sapmnt_path: {{ grains['netweaver_sapmnt_path'] }}
  {%- if grains.get('netweaver_swpm_folder', False) %}
  swpm_folder: {{ grains['netweaver_inst_folder'] }}/{{ grains['netweaver_swpm_folder'] }}
  {%- endif %}
  {%- if grains.get('netweaver_swpm_sar', False) %}
  swpm_sar_file: {{ grains['netweaver_inst_folder'] }}/{{ grains['netweaver_swpm_sar'] }}
  {%- endif %}
  {%- if grains.get('netweaver_sapcar_exe', False) %}
  sapcar_exe_file: {{ grains['netweaver_inst_folder'] }}/{{ grains['netweaver_sapcar_exe'] }}
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
    sid: {{ hana_sid_upper }}
    instance: {{ hana_instance_number }}
    password: {{ grains['hana_master_password'] }}

  schema:
    {%- if product_id_header in ['S4HANA1809', 'S4HANA1909'] %}
    name: SAPHANADB # This name is always used for new S/4HANA, so it shouldn't be changed
    {%- else %}
    name: SAPABAP1
    {%- endif %}
    password: {{ grains['netweaver_master_password'] }}

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
      {%- if grains['provider'] == 'azure' and grains['netweaver_shared_storage_type'] == 'anf' %}
      shared_disk_dev: {{ grains['anf_mount_ip']['sapmnt'][0] }}:/netweaver-sapmnt/ASCS
      {%- else %}
      shared_disk_dev: {{ grains['netweaver_nfs_share'] }}/ASCS
      {%- endif %}
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
      {%- if grains['provider'] == 'azure' and grains['netweaver_shared_storage_type'] == 'anf' %}
      shared_disk_dev: {{ grains['anf_mount_ip']['sapmnt'][0] }}:/netweaver-sapmnt/ERS
      {%- else %}
      shared_disk_dev: {{ grains['netweaver_nfs_share'] }}/ERS
      {%- endif %}
      {%- endif %}
      sap_instance: ers
    {% endif %}

    - host: {{ grains['name_prefix'] }}0{{ app_start_index+1 }}
      virtual_host: sap{{ sid_lower }}pas
      virtual_host_interface: {{ virtual_host_interface }}
      virtual_host_mask: {{ virtual_host_mask }}
      sid: {{ sid_upper }}
      instance: '99' # It is not used, but set a unique number to avoid conflicts on salt code
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

    {%- for index in range(app_server_count-1) %}
    - host: {{ grains['name_prefix'] }}0{{ app_start_index+loop.index+1 }}
      virtual_host: sap{{ sid_lower }}aas{{ loop.index }}
      virtual_host_interface: {{ virtual_host_interface }}
      virtual_host_mask: {{ virtual_host_mask }}
      sid: {{ sid_upper }}
      instance: {{ '{:0>2}'.format(grains['pas_instance_number']+loop.index) }}
      root_user: root
      root_password: linux
      sap_instance: aas
      {%- if product_id_header in ['S4HANA1709'] %}
      attempts: 500
      {%- endif %}
    {% endfor %}
