include:
  {% if grains['provider'] in ('aws', 'gcp',) %}
  - hana_node.add_credentials
  {% if grains['init_type']|default('all') != 'skip-hana' %}
  - hana_node.download_hana_inst
  {% endif %}
  {% else %}
  - hana_node.sap_inst
  {% endif %}
  - hana_node.hosts
  {% if grains['shared_storage_type'] == 'iscsi' %}
  - hana_node.iscsi_initiator
  {% endif %}
  - hana_node.mount
  {% if grains['cluster_ssh_pub'] is defined and grains['cluster_ssh_key'] is defined %}
  - hana_node.ssh
  {% endif %}
  - hana_node.hana_packages
  - hana_node.cluster_packages
  - hana_node.formula
  {% if grains.get('monitoring_enabled') %}
  - hana_node.monitoring
  {% endif %}
