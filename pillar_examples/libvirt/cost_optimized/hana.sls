hana:
  saptune_solution: 'HANA'
  nodes:
    - host: 'hana01'
      sid: 'prd'
      instance: "00"
      password: 'SET YOUR PASSWORD'
      install:
        software_path: '/sapmedia/HANA'
        root_user: 'root'
        root_password: 'linux'
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
      scenario_type: 'cost-optimized'
      cost_optimized_parameters:
        global_allocation_limit: '32100'
        preload_column_tables: False
      install:
        software_path: '/sapmedia/HANA'
        root_user: 'root'
        root_password: 'linux'
        system_user_password: 'SET YOUR PASSWORD'
        sapadm_password: 'SET YOUR PASSWORD'
      secondary:
        name: SECONDARY_SITE_NAME
        remote_host: 'hana01'
        remote_instance: "00"
        replication_mode: 'sync'
        operation_mode: 'logreplay'

    - host: 'hana02'
      sid: 'qas'
      instance: "01"
      password: 'SET YOUR PASSWORD'
      scenario_type: 'cost-optimized'
      cost_optimized_parameters:
        global_allocation_limit: '28600'
        preload_column_tables: False
      install:
        software_path: '/sapmedia/HANA'
        root_user: 'root'
        root_password: 'linux'
        system_user_password: 'SET YOUR PASSWORD'
        sapadm_password: 'SET YOUR PASSWORD'
