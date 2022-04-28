include:
  - hana_node.mount.packages
  {% if grains['provider'] == 'azure' %}
  - hana_node.mount.azure
  {% elif grains['provider'] == 'gcp' %}
  - hana_node.mount.gcp
  {% elif grains['provider'] == 'openstack' %}
  - hana_node.mount.openstack
  {%- if grains['provider'] in ['libvirt'] %}
  - hana_node.mount.lvm
  {% else %}
  - hana_node.mount.mount
  {% endif %}
