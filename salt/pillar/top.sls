base:
  'role:hana_node':
    - match: grain
    - iscsi_initiator

  'role:iscsi_srv':
    - match: grain
    - iscsi_srv
