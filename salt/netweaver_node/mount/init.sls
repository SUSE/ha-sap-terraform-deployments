include:
  - netweaver_node.mount.packages
  {% if grains['provider'] == 'azure' %}
  - netweaver_node.mount.azure
  {% endif %}
