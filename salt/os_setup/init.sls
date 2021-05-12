include:
  {% if grains['provider'] == 'libvirt' %}
  - os_setup.auth_keys
  {% endif %}
  - os_setup.registration
  - os_setup.repos
  - os_setup.minion_configuration
  - os_setup.requirements
  - os_setup.packages
  {% if grains['provider'] == 'libvirt' %}
  - os_setup.ip_workaround
  {% endif %}
