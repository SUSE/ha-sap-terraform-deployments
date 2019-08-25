{% if grains.get('install_from_ha_sap_deployment_repo') %}
# Reduce the ha-factory priority in order to install HA packages from there
Change-ha-factory-priority:
  pkgrepo.managed:
    - name: ha-factory
    - priority: 98
{% endif %}


habootstrap-formula:
  pkg.installed:
    - retry:
        attempts: 3
        interval: 15

{% if grains.get('install_from_ha_sap_deployment_repo') %}
# Restore ha-factory priority to 110 to avoid issues installing sap pattern later on
restore-ha-factory-priority:
  pkgrepo.managed:
    - name: ha-factory
    - priority: 110
    - require:
      - pkg: habootstrap-formula
{% endif %}