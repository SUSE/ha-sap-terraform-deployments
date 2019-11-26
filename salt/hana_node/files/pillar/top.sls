base:
  '*':
{% if grains['init_type']|default('all') != 'skip-hana' %}
    - hana
{% endif %}
{% if grains['init_type']|default('all') != 'skip-cluster' %}
    - cluster
{% endif %}
