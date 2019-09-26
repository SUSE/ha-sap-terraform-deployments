{% import_yaml "/root/salt/netweaver_node/files/pillar/netweaver.sls" as netweaver %}
{% set iprange = ".".join(grains['host_ips'][0].split('.')[0:-1]) %}

cluster:
  install_packages: true
  name: netweaver_cluster
  init: {{ grains['name_prefix'] }}01
  {% if grains['provider'] == 'libvirt' %}
  interface: eth1
  {% else %}
  interface: eth0
  unicast: True
  {% endif %}
  watchdog:
    module: softdog
    device: /dev/watchdog
  sbd:
    device: {{ grains['sbd_disk_device'] }}
  join_timer: 20
  {% if grains['provider'] == 'libvirt' %}
  ntp: pool.ntp.org
  sshkeys:
    overwrite: true
    password: linux
  {% endif %}

  configure:
    method: update
    template:
      # When the package salt-standalone-formulas-configuration is finally released, only the first path will be used
      {% if grains['osrelease_info'][0] == 15 and grains['osrelease_info']|length > 1 and grains['osrelease_info'][1] >= 1 %}
      source: /usr/share/salt-formulas/states/netweaver/templates/cluster_resources.j2
      {% else %}
      source: /srv/salt/netweaver/templates/cluster_resources.j2
      {% endif %}
      parameters:
        sid: {{ netweaver.netweaver.nodes[0].sid }}
        ascs_instance: {{ netweaver.netweaver.nodes[0].instance }}
        ers_instance: {{ netweaver.netweaver.nodes[1].instance }}
        ascs_device: {{ netweaver.netweaver.nodes[0].shared_disk_dev }}2
        ers_device: {{ netweaver.netweaver.nodes[1].shared_disk_dev }}3
        ascs_ip_address: {{ iprange }}.15
        ers_ip_address: {{ iprange }}.16
        ascs_virtual_host: {{ netweaver.netweaver.nodes[0].virtual_host }}
        ers_virtual_host: {{ netweaver.netweaver.nodes[1].virtual_host }}
