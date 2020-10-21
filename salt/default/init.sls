include:
  - default.hostname
  - default.pkgs
{% if grains['provider'] == 'libvirt' %}
  - default.timezone
{% endif %}
