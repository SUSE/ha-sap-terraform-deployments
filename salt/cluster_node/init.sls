include:
  - cluster_node.hosts
  {% if grains.get('ha_enabled', True) %}
  - cluster_node.ha
  {% endif %}
  {% if grains.get('monitoring_enabled') %}
  - cluster_node.monitoring
  {% endif %}
  {%- if grains['provider'] == 'aws' %}
  - cluster_node.aws_add_credentials
  - cluster_node.aws_data_provider
  {%- endif %}
