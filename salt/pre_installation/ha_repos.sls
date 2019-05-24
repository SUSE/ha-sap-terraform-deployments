ha-factory-repo:
  pkgrepo.managed:
    - name: ha-factory
    - baseurl: {{ grains['ha_sap_deployment_repo'] }}
    - gpgautoimport: True
    - priority: 110
    - retry:
        attempts: 3
        interval: 15
