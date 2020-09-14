include:
  - active_directory.setup
  - active_directory.userandgroupid
  {% if grains['role'] == "hana_node" %}
  - active_directory.validate_users
  {% endif %}
