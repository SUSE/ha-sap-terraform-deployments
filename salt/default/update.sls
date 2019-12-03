{% if not grains.get('qa_mode') %}
{% if grains['os_family'] == 'Suse' %}
update_repos:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys update
    - retry:
        attempts: 3
        interval: 15
{% endif %}
{% endif %}
