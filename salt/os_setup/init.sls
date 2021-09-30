include:
  {% if grains['provider'] == 'libvirt' %}
  - os_setup.ip_workaround
  {% endif %}
  - os_setup.auth_keys
  - os_setup.registration
  - os_setup.packages_repos
  - os_setup.minion_configuration
  - os_setup.requirements
  - os_setup.packages_install
  - os_setup.packages_update
