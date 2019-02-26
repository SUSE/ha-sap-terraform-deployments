hana:
  nodes:
    - host: 'hana01'
      sid: 'prd'
      instance: '"00"'
      password: 'Qwerty1234'
      install:
        software_path: '/root/sap_inst/51052481'
        root_user: 'root'
        root_password: 'linux'
        system_user_password: 'Qwerty1234'
        sapadm_password: 'Qwerty1234'
      primary:
        name: NUREMBERG
        backup:
          user: 'backupkey'
          password: 'Qwerty1234'
          database: 'SYSTEMDB'
          file: 'backup'
        userkey:
          key: 'backupkey'
          environment: 'hana01:30013'
          user: 'SYSTEM'
          password: 'Qwerty1234'
          database: 'SYSTEMDB'

    - host: 'hana02'
      sid: 'prd'
      instance: '"00"'
      password: 'Qwerty1234'
      install:
        software_path: '/root/sap_inst/51052481'
        root_user: 'root'
        root_password: 'linux'
        system_user_password: 'Qwerty1234'
        sapadm_password: 'Qwerty1234'
        extra_parameters:
          hostname: 'hana02'
      secondary:
        name: PRAGUE
        remote_host: 'hana01'
        remote_instance: '00'
        replication_mode: 'sync'
        operation_mode: 'logreplay'
