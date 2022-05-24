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
  # make sure cloud_provider grains is set in this salt run (to be available in provisioning run)
  # currently we have possible race condition here https://github.com/saltstack/salt/issues/54331 with salt >=3003
  # SLES 15 SP4 uses salt-3004
  - cluster.cloud_detection
