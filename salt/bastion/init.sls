{% if grains.get('monitoring_enabled', False) %}
include:
  - bastion.nginx
{% else %}
default_nop:
  test.nop: []
{% endif %}
