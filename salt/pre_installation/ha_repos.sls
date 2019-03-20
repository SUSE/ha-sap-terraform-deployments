ha-factory-repo:
  pkgrepo.managed:
    - name: ha-factory
{% if grains['osfinger'] == 'SLES-12' %}
    - baseurl: {{ grains['ha_sap_deployment_repo'] }}/SLE_12_SP4/
{% elif grains['osfinger'] == 'SLES-15' %}
    - baseurl: {{ grains['ha_sap_deployment_repo'] }}/SLE_15/
{% endif %}
    - gpgautoimport: True
