include:
  {% if grains['provider'] in ['aws', 'azure', 'gcp'] %}
  - cluster_node.ha.network
  {% endif %}
  - cluster_node.ha.packages
  {% if grains['cluster_ssh_pub'] is defined and grains['cluster_ssh_key'] is defined %}
  - cluster_node.ha.ssh
  {% endif %}
  {% if grains['fencing_mechanism'] == 'sbd' and grains['sbd_storage_type'] == 'iscsi' %}
  - cluster_node.ha.iscsi_initiator
  {% endif %}
