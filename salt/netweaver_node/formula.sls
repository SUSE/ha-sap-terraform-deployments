/srv/pillar:
  file.directory:
    - user: root
    - mode: '0755'
    - makedirs: True

/srv/salt/top.sls:
  file.copy:
    - source: /root/salt/netweaver_node/files/salt/top.sls

/srv/pillar/top.sls:
  file.copy:
    - source: /root/salt/netweaver_node/files/pillar/top.sls

/srv/pillar/netweaver.sls:
  file.copy:
    - source: /root/salt/netweaver_node/files/pillar/netweaver.sls

/srv/pillar/cluster.sls:
  file.copy:
    - source: /root/salt/netweaver_node/files/pillar/cluster.sls
