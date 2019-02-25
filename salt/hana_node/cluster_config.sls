{% if grains['qa_mode'] is sameas false %}
  {% set directory = 'files' %}
{% else %}
  {% set directory = 'QA_templates' %}
{% endif %}

/tmp/cluster.config:
  file.managed:
    - source: /root/salt/hana_node/{{ directory }}/config/cluster.j2
    - user: root
    - group: root
    - mode: 644
    - template: jinja
