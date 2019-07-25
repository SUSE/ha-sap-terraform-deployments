base:
  'role:hana_node':
    - match: grain
    - default
    - hana_node

  'role:iscsi_srv':
    - match: grain
    - iscsi_srv

 
  'role:monitoring':
    - match: grain
    - monitoring
