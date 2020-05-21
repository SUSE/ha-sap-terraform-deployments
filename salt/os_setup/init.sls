include:
  - os_setup.registration
  - os_setup.repos
  - os_setup.update
  - os_setup.ha_repos
  - os_setup.minion_configuration
  - os_setup.packages
  {% if grains['provider'] == 'libvirt' %}
  - os_setup.ip_workaround
  {% endif %}
