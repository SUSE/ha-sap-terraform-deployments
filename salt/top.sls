base:
  'role:hana_node':
    - match: grain
    - hana

  'role:majority_maker_node':
    - match: grain
    - cluster

  'G@role:hana_node and G@ha_enabled:true':
    - match: compound
    - cluster

  'role:drbd_node':
    - match: grain
    - drbd
    - cluster

  'role:netweaver_node':
    - match: grain
    - netweaver

  'G@role:netweaver_node and G@ha_enabled:true and P@hostname:.*(01|02)':
    - match: compound
    - cluster

predeployment:
  'role:hana_node':
    - match: grain
    - default
    - cluster_node
    - hana_node

  'role:netweaver_node':
    - match: grain
    - default
    - cluster_node
    - netweaver_node

  'role:drbd_node':
    - match: grain
    - default
    - cluster_node
    - drbd_node

  'role:iscsi_srv':
    - match: grain
    - iscsi_srv

  'role:monitoring_srv':
    - match: grain
    - default
    - monitoring_srv

  'role:bastion':
    - match: grain
    - bastion

  'role:majority_maker_node':
    - match: grain
    - default
    - cluster_node
