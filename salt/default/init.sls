include:
{% if grains['provider'] != 'aws' %}
  - default.minimal
{% endif %}
{% if grains['os_family'] == 'Suse' %}
  - default.registration
{% endif %}
  - default.repos
  - default.pkgs
{% if grains['provider'] != 'aws' %}
{% if grains['ntp_server'] != ''%}
  - default.ntp
{% endif %}
  - default.timezone
  - default.auth_keys
refresh_repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
{% endif %}
