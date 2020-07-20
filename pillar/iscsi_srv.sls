{% set devicenum = 'abcdefghijklmnopqrstuvwxyz' %}
{% set partitions = grains['partitions'] %}
{% set real_iscsidev = salt['cmd.run']('realpath '~grains['iscsidev']) %}

iscsi:
  target:
    pkgs:
      wanted:
      {%- if grains['osmajorrelease'] == 12 %}
        - targetcli-fb
        - python-dbus-python
      {%- else %}
        - targetcli-fb-common
        - python3-targetcli-fb
      {%- endif %}
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
{%- for partition in partitions %}
          sd{{ devicenum[loop.index0] }}:
            attributes:
              block_size: 512
              emulate_write_cache: 0
              unmap_granularity: 0
            dev: {{ real_iscsidev }}{{ loop.index }}
            name: sd{{ devicenum[loop.index0] }}
            plugin: "block"
{%- endfor %}
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
{%- for partition in partitions %}
                sd{{ devicenum[loop.index0] }}:
                  index: {{ loop.index0 }}
                  storage_object: /backstores/block/sd{{ devicenum[loop.index0] }}
{%- endfor %}
              portals:
                iscsi_server:
                  ip_address: {{ grains['iscsi_srv_ip'] }}
                  port: 3260
              tag: 1
            wwn: "iqn.1996-04.de.suse:01:a66aed20e2f3"
