include:
  - majority_maker_node.packages
  {% if grains['cluster_ssh_pub'] is defined and grains['cluster_ssh_key'] is defined %}
  - majority_maker_node.wait
  {% endif %}
