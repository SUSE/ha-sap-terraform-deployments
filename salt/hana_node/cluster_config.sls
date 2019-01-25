/tmp/cluster.config:
  file.managed:
    - source: /root/salt/hana_node/files/config/cluster.j2
    - user: root
    - group: root
    - mode: 644
    - template: jinja
