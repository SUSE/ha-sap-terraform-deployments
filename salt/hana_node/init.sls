include:
  {% if grains['provider'] in ('aws', 'gcp',) %}
  {% if grains['init_type']|default('all') != 'skip-hana' %}
  - hana_node.download_hana_inst
  {% endif %}
  {% else %}
  - hana_node.hana_inst_media
  {% endif %}
  - hana_node.mount
  - hana_node.hana_packages
  - hana_node.formula
