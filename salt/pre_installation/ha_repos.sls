ha-factory-repo:
  pkgrepo.managed:
    - name: ha-factory
    - baseurl: {{ grains['ha_sap_deployment_repo'] }}
    - gpgautoimport: True
    # Reduce the ha-factory priority in order to install HA packages from there
    {% if grains.get('devel_mode') %}
    - priority: 98
    {% else %}
    - priority: 110
    {% endif %}
    - refresh: True
    - retry:
        attempts: 3
        interval: 15
