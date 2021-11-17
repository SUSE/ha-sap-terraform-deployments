include:
  {% if grains['hana_scale_out_enabled']|default(false) %}
  - hana_node.hana_packages
  {% if grains['cluster_ssh_pub'] is defined and grains['cluster_ssh_key'] is defined %}
  - hana_node.wait
  {% endif %}
  {% endif %}
