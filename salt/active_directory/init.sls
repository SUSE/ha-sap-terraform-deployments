include:
  - active_directory.setup
  {% if grains['role'] == "hana_node" %}
  - active_directory.validate_users
  {% endif %}
