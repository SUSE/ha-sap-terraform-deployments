base:
  'role:iscsi_srv':
    - match: grain
    {% if not grains.get('qa_mode', False) %}
    - iscsi_srv
    {% else %}
    - iscsi_srv_qa
    {% endif %}
