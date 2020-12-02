include:
  - default.pkgs
{% if grains['provider'] == 'libvirt' %}
  - default.timezone
{% endif %}
