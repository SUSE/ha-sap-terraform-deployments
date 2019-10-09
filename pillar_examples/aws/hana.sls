hana:
  # install_packages: false # disable pre defined pacakge installation
  nodes:
    - host: 'hana01'
      sid: 'prd'
      instance: "00"
      password: 'SET YOUR PASSWORD'
      install:
        software_path: '/root/sap_inst/'
        root_user: 'root'
        root_password: ''
        system_user_password: 'SET YOUR PASSWORD'
        sapadm_password: 'SET YOUR PASSWORD'
      primary:
        name: PRIMARY_SITE_NAME
        backup:
          key_name: 'backupkey'
          database: 'SYSTEMDB'
          file: 'backup'
        userkey:
          key_name: 'backupkey'
          environment: 'hana01:30013'
          user_name: 'SYSTEM'
          user_password: 'SET YOUR PASSWORD'
          database: 'SYSTEMDB'

    - host: 'hana02'
      sid: 'prd'
      instance: "00"
      password: 'SET YOUR PASSWORD'
      install:
        software_path: '/root/sap_inst/'
        root_user: 'root'
        root_password: ''
        system_user_password: 'SET YOUR PASSWORD'
        sapadm_password: 'SET YOUR PASSWORD'
      secondary:
        name: SECONDARY_SITE_NAME
        remote_host: 'hana01'
        remote_instance: "00"
        replication_mode: 'sync'
        operation_mode: 'logreplay'
