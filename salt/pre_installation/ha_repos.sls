ha-factory-repo:
  pkgrepo.managed:
    - name: ha-factory
    - baseurl: {{ grains['ha_sap_deployment_repo'] }}
    - gpgautoimport: True
    {% if grains['install_from_ha_sap_deployment_repo'] is defined and grains['install_from_ha_sap_deployment_repo'] == true %}  # TODO: Very long line
    - priority: 98
    {% else %}
    - priority: 110
    {% endif %}
    - refresh: True
    - retry:
        attempts: 3
        interval: 15
