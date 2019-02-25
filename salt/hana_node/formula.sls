{% if grains['qa_mode'] is sameas false %}
  {% set directory = 'files' %}
{% else %}
  {% set directory = 'QA_templates' %}
{% endif %}

/srv/pillar:
  file.directory:
    - user: root
    - mode: 755
    - makedirs: True

/srv/salt/top.sls:
  file.copy:
    - source: /root/salt/hana_node/{{ directory }}/salt/top.sls

/srv/pillar/top.sls:
  file.copy:
    - source: /root/salt/hana_node/{{ directory }}/pillar/top.sls

/srv/pillar/hana.sls:
  file.copy:
    - source: /root/salt/hana_node/{{ directory }}/pillar/hana.sls

/srv/pillar/cluster.sls:
  file.copy:
    - source: /root/salt/hana_node/{{ directory }}/pillar/cluster.sls
