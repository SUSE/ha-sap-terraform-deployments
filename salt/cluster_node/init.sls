include:
  {% if grains['provider'] in ['aws', 'azure', 'gcp'] %}
  - network
  {% endif %}
  - cluster_node.hosts
  - cluster_node.cluster_packages
  {% if grains['cluster_ssh_pub'] is defined and grains['cluster_ssh_key'] is defined %}
    - default.ssh
  {% endif %}
  {% if grains['shared_storage_type'] == 'iscsi' %}
  - cluster_node.iscsi_initiator
  {% endif %}
  {% if grains.get('monitoring_enabled') %}
  - cluster_node.monitoring
  {% endif %}
