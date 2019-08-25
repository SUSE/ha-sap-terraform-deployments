{% if grains.get('ha_pkgs_from_factory') %}
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
