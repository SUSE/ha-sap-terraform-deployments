include:
  - hana_node.network
  {% if grains['provider'] in ('aws', 'gcp',) %}
  - hana_node.add_credentials
  {% if grains['init_type']|default('all') != 'skip-hana' %}
  - hana_node.download_hana_inst
  {% endif %}
  {% else %}
  - hana_node.hana_inst_media
  {% endif %}
  - hana_node.hosts
  {% if grains['shared_storage_type'] == 'iscsi' %}
  - hana_node.iscsi_initiator
  {% endif %}
  - hana_node.mount
  - hana_node.hana_packages
  - hana_node.cluster_packages
  - hana_node.formula
  {% if grains.get('monitoring_enabled') %}
  - hana_node.monitoring
  {% endif %}
