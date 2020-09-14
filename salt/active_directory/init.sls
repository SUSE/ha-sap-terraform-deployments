include:
  - active_directory.setup
  - active_directory.set_ad_grains
  {% if grains['role'] == "hana_node" %}
  - active_directory.validate_users
  {% endif %}
