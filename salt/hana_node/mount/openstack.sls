include:
{%- if grains['hana_scale_out_enabled'] and grains['hana_scale_out_shared_storage_type'] == "nfs" %}
  - shared_storage.nfs
{%- else %}
  - hana_node.mount.mount
{%- endif %}
