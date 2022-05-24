include:
  - hana_node.mount.packages
  {%- if grains['provider'] in ['aws', 'azure', 'gcp', 'libvirt', 'openstack'] %}
  - hana_node.mount.lvm
  {% else %}
  - hana_node.mount.mount
  {% endif %}
