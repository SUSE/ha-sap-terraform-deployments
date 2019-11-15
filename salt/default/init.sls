include:
{% if grains['provider'] == 'libvirt' %}
  - default.minimal
{% endif %}
  - default.hostname
{% if grains.get('host_ips') %}
  - default.hosts
{% endif %}
{% if grains['os_family'] == 'Suse' %}
  - default.registration
{% endif %}
  - default.repos
  - default.pkgs
{% if grains['provider'] == 'libvirt' %}
  - default.timezone
  - default.auth_keys
{% endif %}
