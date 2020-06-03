base:
  '*':
    - netweaver

  'G@ha_enabled:true and P@hostname:.*(01|02)':
    - match: compound
    - cluster
