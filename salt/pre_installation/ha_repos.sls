ha-factory-repo:
  pkgrepo.managed:
    - name: ha-factory
{% if grains['osmajorrelease'] == 12 %}
    - baseurl: {{ grains['ha_sap_deployment_repo'] }}/SLE_12_SP4/
{% elif grains['osmajorrelease'] == 15 %}
    - baseurl: {{ grains['ha_sap_deployment_repo'] }}/SLE_15/
{% endif %}
    - gpgautoimport: True
