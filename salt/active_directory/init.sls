include:
  - active_directory.setup
  - active_directory.grain_users
  {% if grains['role'] == "hana_node" %}
  - active_directory.validate_users
  {% endif %}
