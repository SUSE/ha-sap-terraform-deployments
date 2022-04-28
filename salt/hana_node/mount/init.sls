include:
  - hana_node.mount.packages
  {% if grains['provider'] == 'azure' %}
  - hana_node.mount.azure
  {%- if grains['provider'] in ['gcp', 'libvirt', 'openstack'] %}
  - hana_node.mount.lvm
  {% else %}
  - hana_node.mount.mount
  {% endif %}
