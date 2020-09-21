include:
  {% if grains['provider'] in ('aws', 'gcp',) %}
  - hana_node.download_hana_inst
  {% else %}
  - hana_node.hana_inst_media
  {% endif %}
  - hana_node.mount
  - hana_node.hana_packages
