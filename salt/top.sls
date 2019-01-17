base:
  '*':
    - default

  'role:hana_node':
    - match: grain
    - hana_node
