include:
  {% if grains['provider'] in ['aws', 'azure', 'gcp'] %}
  - cluster_node.network
  {% endif %}
  - cluster_node.hosts
  - cluster_node.cluster_packages
  {% if grains.get('cluster_ssh_pub', None) and grains.get('cluster_ssh_key', None) %}
  - cluster_node.ssh
  {% endif %}
  {% if grains['shared_storage_type'] == 'iscsi' %}
  - cluster_node.iscsi_initiator
  {% endif %}
  {% if grains.get('monitoring_enabled') %}
  - cluster_node.monitoring
  {% endif %}
