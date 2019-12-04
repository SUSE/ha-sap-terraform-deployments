{% if not grains.get('qa_mode') %}
{% if grains['os_family'] == 'Suse' %}
update_system_packages:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys update --no-recommends
    - retry:
        attempts: 3
        interval: 15
{% endif %}
{% endif %}
