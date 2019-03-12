include:
{% if grains['provider'] == 'aws' %}
  - hana_node.add_credentials
  - hana_node.iscsi_initiator
  {% if grains['init_type']|default('all') != 'skip-hana' %}
  - hana_node.download_hana_inst
  {% endif %}
{% else %}
  - hana_node.sap_inst
  - hana_node.hosts
{% endif %}
  - hana_node.mount
  {% if grains['cluster_ssh_pub'] is defined and grains['cluster_ssh_key'] is defined %}
  - hana_node.ssh
  {% endif %}
  - hana_node.hana_packages
  - hana_node.cluster_packages
  - hana_node.formula
