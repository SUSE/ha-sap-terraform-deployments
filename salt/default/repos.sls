{% if grains['os_family'] == 'Suse' %}
refresh_repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - retry:
        attempts: 3
        interval: 15
{% endif %}
