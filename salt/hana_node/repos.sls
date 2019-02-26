ha-factory-repo:
  pkgrepo.managed:
    - name: ha-factory
    - baseurl: {{ grains['ha_factory_repo'] }}
    - gpgautoimport: True
