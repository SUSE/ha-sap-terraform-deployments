hana:
  {% if grains.get('qa_mode') %}
  install_packages: false
  {% endif %}
  {%- if grains.get('hana_platform_folder', False) %}
  software_path: {{ grains['hana_inst_folder'] }}/{{ grains['hana_platform_folder'] }}
  {%- elif grains.get('hana_sapcar_exe', False) and grains.get('hdbserver_sar', False) %}
  sapcar_exe_file: {{ grains['hana_inst_folder'] }}/{{ grains['hana_sapcar_exe'] }}
  hdbserver_sar_file: {{ grains['hana_inst_folder'] }}/{{ grains['hdbserver_sar'] }}
  {%- else %}
  software_path: {{ grains['hana_inst_folder'] }}
  {%- endif %}
  {%- if grains.get('hana_extract_dir', False) %}
  hdbserver_extract_dir: {{ grains['hana_extract_dir'] }}
  {%- endif %}
  saptune_solution: 'HANA'
  nodes:
    - host: {{ grains['name_prefix'] }}01
      sid: prd
      instance: "00"
      password: YourPassword1234
      install:
        root_user: root
        {% if grains['provider'] == 'libvirt' %}
        root_password: linux
        {% else %}
        root_password: ''
        {% endif %}
        system_user_password: YourPassword1234
        sapadm_password: YourPassword1234
      primary:
        name: PRIMARY_SITE_NAME
        backup:
          key_name: backupkey
          database: SYSTEMDB
          file: backup
        userkey:
          key_name: backupkey
          environment: {{ grains['name_prefix'] }}01:30013
          user_name: SYSTEM
          user_password: YourPassword1234
          database: SYSTEMDB
    {% if grains.get('monitoring_enabled', False) %}
      exporter:
        exposition_port: 9668
        user: SYSTEM
        password: YourPassword1234
    {% endif %}

    - host: {{ grains['name_prefix'] }}02
      sid: prd
      instance: "00"
      password: YourPassword1234
      {% if grains['scenario_type'] == 'cost-optimized' %}
      scenario_type: 'cost-optimized'
      cost_optimized_parameters:
        global_allocation_limit: '32100'
        preload_column_tables: False
      {% endif %}
      install:
        root_user: root
        {% if grains['provider'] == 'libvirt' %}
        root_password: linux
        {% else %}
        root_password: ''
        {% endif %}
        system_user_password: YourPassword1234
        sapadm_password: YourPassword1234
      secondary:
        name: SECONDARY_SITE_NAME
        remote_host: {{ grains['name_prefix'] }}01
        remote_instance: "00"
        replication_mode: sync
        operation_mode: logreplay
        primary_timeout: 3000
    {% if grains['scenario_type'] == 'cost-optimized' %}
    - host: {{ grains['name_prefix'] }}02
      sid: qas
      instance: "01"
      password: YourPassword1234
      scenario_type: 'cost-optimized'
      cost_optimized_parameters:
        global_allocation_limit: '28600'
        preload_column_tables: False
      install:
        root_user: root
        {% if grains['provider'] == 'libvirt' %}
        root_password: linux
        {% else %}
        root_password: ''
        {% endif %}
        system_user_password: YourPassword1234
        sapadm_password: YourPassword1234
      {% if grains.get('monitoring_enabled', False) %}
      exporter:
        exposition_port: 9669
        user: SYSTEM
        password: YourPassword1234
      {% endif %}
    {% endif %}
