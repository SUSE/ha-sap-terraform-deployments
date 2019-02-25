base:
  '*':
{% if grains['init_type'] != 'skip-hana' %}
    - hana
{% endif %}
{% if grains['init_type'] != 'skip-cluster' %}
    - cluster
{% endif %}
