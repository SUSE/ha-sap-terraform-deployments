iscsi:
  isns:
    enabled: false
  target:
    lio:
      myconf:
        fabric_modules:
          authenticate_target: 'false'
          enforce_discovery_auth: 'false'
          name: "iscsi"
        storage_objects:
          attributes:
            block_size: 512
            emulate_write_cache: 0
            queue_depth: 64
            unmap_granularity: 0
          dev: "/dev/xvdd1"
          name: "sda"
          plugin: "block"
        targets:
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
              index: 0
              storage_object: "/backstores/block/sda"
            portals:
              ip_address: {{ grains['iscsi_srv_ip'] }}
              port: 3260
            tag: 1
          wwn: "iqn.1996-04.de.suse:01:a66aed20e2f3"
