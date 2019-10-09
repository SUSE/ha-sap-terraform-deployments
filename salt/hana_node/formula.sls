/srv/pillar:
  file.directory:
    - user: root
    - mode: "0755"
    - makedirs: True

/srv/salt/top.sls:
  file.copy:
    - source: /root/salt/hana_node/files/salt/top.sls

/srv/pillar/top.sls:
  file.copy:
    - source: /root/salt/hana_node/files/pillar/top.sls

/srv/pillar/hana.sls:
  file.copy:
    - source: /root/salt/hana_node/files/pillar/hana.sls

/srv/pillar/cluster.sls:
  file.copy:
    - source: /root/salt/hana_node/files/pillar/cluster.sls
