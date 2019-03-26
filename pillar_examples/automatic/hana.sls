hana:
  {% if grains['qa_mode']|default(false) is sameas true %}
  install_packages: false
  {% endif %}
  nodes:
    - host: {{ grains['name_prefix'] }}01
      sid: prd
      instance: 00
      password: YourPassword1234
      install:
        software_path: /root/sap_inst
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

    - host: {{ grains['name_prefix'] }}02
      sid: prd
      instance: 00
      password: YourPassword1234
      install:
        software_path: /root/sap_inst
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
        remote_instance: 00
        replication_mode: sync
        operation_mode: logreplay
        primary_timeout: 3000
