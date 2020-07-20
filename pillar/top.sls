base:
  'role:iscsi_srv':
    - match: grain
    - iscsi_srv

  'role:hana_node':
    - match: grain
    - hana.hana

  'G@role:hana_node and G@ha_enabled:true':
    - match: compound
    - hana.cluster

  'role:drbd_node':
    - match: grain
    - drbd.drbd
    - drbd.cluster

  'role:netweaver_node':
    - match: grain
    - netweaver.netweaver

  'G@role:netweaver_node and G@ha_enabled:true and P@hostname:.*(01|02)':
    - match: compound
    - netweaver.cluster
