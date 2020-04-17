cluster:
  install_packages: true
  name: 'drbd_cluster'
  init: {{ grains['name_prefix'] }}01
  {% if grains['provider'] == 'libvirt' %}
  interface: eth1
  {% else %}
  interface: eth0
  {% endif %}
  unicast: True
  wait_for_initialization: 20
  join_timeout: 180
  watchdog:
    module: softdog
    device: /dev/watchdog
  sbd:
    device: {{ grains['sbd_disk_device'] }}
  ntp: pool.ntp.org
  {% if grains['provider'] == 'libvirt' %}
  sshkeys:
    overwrite: true
    password: linux
  {% endif %}
  {% if grains['provider'] == 'azure' %}
  corosync:
    totem:
      token: 30000
      token_retransmits_before_loss_const: 10
      join: 60
      consensus: 36000
      max_messages: 20
  {% endif %}
  {% if grains.get('monitoring_enabled', False) %}
  ha_exporter: true
  {% else %}
  ha_exporter: false
  {% endif %}

  configure:
    method: 'update'
    template:
      source: /srv/salt/drbd_files/templates/drbd_cluster.j2
      parameters:
        {% if grains['provider']== "azure" %}
        probe: 61000
        {% elif grains['provider'] == 'gcp' %}
        virtual_ip: {{ grains['drbd_cluster_vip'] }}
        vpc_network_name: {{ grains['vpc_network_name'] }}
        route_table: {{ grains['route_table'] }}
        {% endif %}
