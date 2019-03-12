{% set primary_node = 'hana01' %}
{% set secondary_node = 'hana02' %}

hana:
  {% if grains['qa_mode']|default(false) is sameas true %}
  install_packages: false
  {% endif %}
  nodes:
    - host: {{ primary_node }}
      sid: 'prd'
      instance: 00
      password: 'Qwerty1234'
      install:
        software_path: '/root/sap_inst/'
        root_user: 'root'
        {% if grains['provider'] == 'libvirt' %}
        root_password: 'linux'
        {% else %}
        root_password: ''
        {% endif %}
        system_user_password: 'Qwerty1234'
        sapadm_password: 'Qwerty1234'
      primary:
        name: NUE
        backup:
          key_name: 'backupkey'
          database: 'SYSTEMDB'
          file: 'backup'
        userkey:
          key_name: 'backupkey'
          environment: '{{ primary_node }}:30013'
          user_name: 'SYSTEM'
          user_password: 'Qwerty1234'
          database: 'SYSTEMDB'

    - host: {{ secondary_node }}
      sid: 'prd'
      instance: 00
      password: 'Qwerty1234'
      install:
        software_path: '/root/sap_inst/'
        root_user: 'root'
        {% if grains['provider'] == 'libvirt' %}
        root_password: 'linux'
        {% else %}
        root_password: ''
        {% endif %}
        system_user_password: 'Qwerty1234'
        sapadm_password: 'Qwerty1234'
      secondary:
        name: PRAGUE
        remote_host: {{ primary_node }}
        remote_instance: 00
        replication_mode: 'sync'
        operation_mode: 'logreplay'
