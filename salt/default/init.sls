include:
  - default.hostname
  - default.pkgs
{% if grains['provider'] == 'libvirt' %}
  - default.timezone
  - default.auth_keys
{% endif %}
