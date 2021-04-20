{% if grains.get('monitoring_enabled', False) or grains.get('bastion_data_disk_type') in ['ephemeral', 'volume'] %}
include:
{% if grains.get('monitoring_enabled', False) %}
  - bastion.nginx
{% endif %}
{% if grains.get('data_disk_type') in ['ephemeral', 'volume'] %}
  - bastion.sapinst
{% endif %}
{% else %}
default_nop:
  test.nop: []
{% endif %}
