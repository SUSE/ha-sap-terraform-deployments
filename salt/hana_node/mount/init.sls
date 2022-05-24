include:
  - hana_node.mount.packages
  {%- if grains['provider'] in ['aws', 'azure', 'gcp', 'libvirt', 'openstack'] %}
  - hana_node.mount.lvm
  {% else %}
  - hana_node.mount.mount
  {% endif %}
  {%- if grains['hana_scale_out_enabled'] %}
  {%- if grains['hana_scale_out_shared_storage_type'] in ['anf', 'efs', 'filestore', 'nfs'] %}
  - shared_storage.nfs
  {%- endif %}
  {%- endif %}
