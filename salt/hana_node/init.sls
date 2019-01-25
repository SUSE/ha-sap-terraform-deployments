include:
  - hana_node.repos
  - hana_node.mount
  - hana_node.sap_inst
  - hana_node.hosts
  {% if grains['cluster_ssh_pub'] != '' and grains['cluster_ssh_key'] != '' %}
  - hana_node.ssh
  {% endif %}
  - hana_node.hana_packages
  - hana_node.cluster_packages
  - hana_node.formula
  - hana_node.cluster_config
  - hana_node.watchdog
