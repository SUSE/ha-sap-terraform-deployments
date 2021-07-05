{# NFS server used for '/sapinst' on bastion is only available on openstack. #}
{% if grains.get('monitoring_enabled', False) or grains.get('data_disk_type') in ['rootdisk', 'ephemeral', 'volume'] %}
include:
{% if grains.get('monitoring_enabled', False) %}
  - bastion.nginx
{% endif %}
{% if grains.get('data_disk_type') in ['rootdisk', 'ephemeral', 'volume'] %}
  - bastion.sapinst
{% endif %}
{% else %}
default_nop:
  test.nop: []
{% endif %}
