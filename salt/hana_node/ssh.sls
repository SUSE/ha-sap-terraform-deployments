
cluster:
  ssh_auth.present:
    - source: {{grains['cluster_ssh_pub']}}
    - user: root
    - config: '/%u/.ssh/authorized_keys'

/root/.ssh/id_rsa:
  file.managed:
    - source: {{grains['cluster_ssh_key']}}
    - user: root
    - group: root
    - mode: 600

/root/.ssh/id_rsa.pub:
  file.managed:
    - source: {{grains['cluster_ssh_pub']}}
    - user: root
    - group: root
    - mode: 644
