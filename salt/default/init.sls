include:
  - default.hostname
{% if grains['os_family'] == 'Suse' %}
  - default.registration
{% endif %}
  - default.repos
  - default.update
  - default.pkgs
{% if grains['provider'] == 'libvirt' %}
  - default.timezone
  - default.auth_keys
{% endif %}
