include:
  - drbd_node.hosts
  - drbd_node.drbd_packages
  - drbd_node.cluster_packages
  - drbd_node.parted
  - drbd_node.formula
  {% if grains['shared_storage_type'] == 'iscsi' %}
  - drbd_node.iscsi_initiator
  {% endif %}
  {% if grains.get('monitoring_enabled') %}
  - drbd_node.monitoring
  {% endif %}
  - drbd_node.custom_handlers
