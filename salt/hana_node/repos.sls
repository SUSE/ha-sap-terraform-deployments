ha-factory-repo:
  pkgrepo.managed:
    - name: ha-factory
    - baseurl: {{ grains['ha_sap_deployment_repo'] }}
    - gpgautoimport: True
