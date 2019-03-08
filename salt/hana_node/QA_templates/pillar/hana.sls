hana:
  install_packages: false
  nodes:
    - host: 'ip-10-0-1-0'
      sid: 'prd'
      instance: '"00"'
      password: 'Qwerty1234'
      install:
        software_path: '/root/sap_inst/'
        root_user: 'root'
        root_password: ''
        system_user_password: 'Qwerty1234'
        sapadm_password: 'Qwerty1234'
      primary:
        name: PRIMARY_SITE_NAME
        backup:
          key_name: 'backupkey'
          database: 'SYSTEMDB'
          file: 'backup'
        userkey:
          key_name: 'backupkey'
          environment: 'ip-10-0-1-0:30013'
          user_name: 'SYSTEM'
          user_password: 'Qwerty1234'
          database: 'SYSTEMDB'

    - host: 'ip-10-0-1-1'
      sid: 'prd'
      instance: '"00"'
      password: 'Qwerty1234'
      install:
        software_path: '/root/sap_inst/'
        root_user: 'root'
        root_password: ''
        system_user_password: 'Qwerty1234'
        sapadm_password: 'Qwerty1234'
      secondary:
        name: SECONDARY_SITE_NAME
        remote_host: 'ip-10-0-1-0'
        remote_instance: '00'
        replication_mode: 'sync'
        operation_mode: 'logreplay'
