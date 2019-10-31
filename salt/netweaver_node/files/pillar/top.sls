base:
  '*':
    - netweaver

  'hostname:.*(01|02)':
    - match: grain_pcre
    - cluster
