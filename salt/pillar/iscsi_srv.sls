iscsi:
  target:
    pkgs:
      wanted:
        - targetcli-fb-common
        - python3-targetcli-fb
        - yast2-iscsi-lio-server
  config:
    data:
      lio:
        fabric_modules:
          iscsi_server:
            authenticate_target: 'false'
            enforce_discovery_auth: 'false'
            name: "iscsi"
        storage_objects:
          sda:
            attributes:
              block_size: 512
              emulate_write_cache: 0
              queue_depth: 64
              unmap_granularity: 0
            dev: {{ grains['iscsidev'] }}1
            name: "sda"
            plugin: "block"
          sdb:
            attributes:
              block_size: 512
              emulate_write_cache: 0
              queue_depth: 64
              unmap_granularity: 0
            dev: {{ grains['iscsidev'] }}2
            name: "sdb"
            plugin: "block"
          sdc:
            attributes:
              block_size: 512
              emulate_write_cache: 0
              queue_depth: 64
              unmap_granularity: 0
            dev: {{ grains['iscsidev'] }}3
            name: "sdc"
            plugin: "block"
        targets:
          iscsi_server:
            fabric: iscsi
            tpgs:
              attributes:
                  authentication: 0
                  cache_dynamic_acls: 0
                  default_cmdsn_depth: 16
                  demo_mode_write_protect: 0
                  generate_node_acls: 1
                  login_timeout: 15
                  netif_timeout: 2
                  prod_mode_write_protect: 0
              luns:
                sda:
                  index: 0
                  storage_object: /backstores/block/sda
                sdb:
                  index: 1
                  storage_object: /backstores/block/sdb
                sdc:
                  index: 2
                  storage_object: /backstores/block/sdc
              portals:
                iscsi_server:
                  ip_address: {{ grains['iscsi_srv_ip'] }}
                  port: 3260
              tag: 1
            wwn: "iqn.1996-04.de.suse:01:a66aed20e2f3"
