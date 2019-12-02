{% if grains['os_family'] == 'Suse' %}
refresh_repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys update
    - retry:
        attempts: 3
        interval: 15
{% endif %}
