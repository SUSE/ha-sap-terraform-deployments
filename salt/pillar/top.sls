base:
  'role:hana_node':
    - match: grain
    {% if grains['provider'] == 'aws' %}
    - iscsi_initiator
    {% endif %}

  'role:iscsi_srv':
    - match: grain
    - iscsi_srv
