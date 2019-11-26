base:
  'role:hana_node':
    - match: grain
    - default
    - hana_node

  'role:netweaver_node':
    - match: grain
    - default
    - netweaver_node

  'role:drbd_node':
    - match: grain
    - default
    - drbd_node

  'role:iscsi_srv':
    - match: grain
    - iscsi_srv

  'role:monitoring':
    - match: grain
    - default
    - monitoring
