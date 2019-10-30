/srv/pillar:
  file.directory:
    - user: root
    - mode: "0755"
    - makedirs: True

/srv/salt:
  file.directory:
    - user: root
    - mode: "0755"
    - makedirs: True

/srv/salt/top.sls:
  file.copy:
    - source: /root/salt/drbd_node/files/salt/top.sls

/srv/salt/drbd_files/templates/drbd_cluster.j2:
  file.copy:
    - source: /root/salt/drbd_node/files/templates/drbd_cluster.j2
    - makedirs: True

/srv/pillar/top.sls:
  file.copy:
    - source: /root/salt/drbd_node/files/pillar/top.sls

/srv/pillar/drbd.sls:
  file.copy:
    - source: /root/salt/drbd_node/files/pillar/drbd.sls

/srv/pillar/cluster.sls:
  file.copy:
    - source: /root/salt/drbd_node/files/pillar/cluster.sls
