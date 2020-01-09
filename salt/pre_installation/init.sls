include:
  - pre_installation.registration
  - pre_installation.repos
  - pre_installation.update
  - pre_installation.ha_repos
  - pre_installation.minion_configuration
  - pre_installation.packages
  {% if grains['provider'] == 'libvirt' %}
  - pre_installation.ip_workaround
  {% endif %}
