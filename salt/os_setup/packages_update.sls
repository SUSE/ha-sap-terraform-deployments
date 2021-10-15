{% if grains['os_family'] == 'Suse' %}

{% if not grains.get('offline_mode') %}
update_system_packages:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys update --no-recommends --auto-agree-with-licenses
    - retry:
        attempts: 3
        interval: 15
{% endif %}

{% endif %}
