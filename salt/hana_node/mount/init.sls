include:
  - hana_node.mount.packages
  {% if grains['provider'] == 'azure' %}
  - hana_node.mount.azure
  {% elif grains['provider'] == 'gcp' %}
  - hana_node.mount.gcp
  {% else %}
  - hana_node.mount.mount
  {% endif %}
