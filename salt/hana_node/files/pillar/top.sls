base:
  '*':
    - hana

  'ha_enabled:true':
    - match: grain
    - cluster
