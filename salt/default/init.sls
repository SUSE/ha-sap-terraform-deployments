include:
{% if grains['provider'] == 'libvirt' %}
  - default.minimal
{% endif %}
{% if grains['os_family'] == 'Suse' %}
  - default.registration
{% endif %}
  - default.repos
  - default.pkgs
{% if grains['provider'] == 'libvirt' %}
  - default.timezone
  - default.auth_keys
refresh_repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
{% endif %}
