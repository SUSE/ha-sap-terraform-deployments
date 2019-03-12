{% import_yaml "/root/salt/hana_node/files/pillar/hana.sls" as hana %}

cluster:
  {% if grains['qa_mode']|default(false) is sameas true %}
  install_packages: false
  {% endif %}
  name: 'hacluster'
  init: {{ hana.primary_node }}
  {% if grains['provider'] == 'libvirt' %}
  interface: 'eth1'
  {% elif grains['provider'] == 'aws' %}
  interface: 'eth0'
  {% endif %}
  watchdog:
    module: softdog
    device: /dev/watchdog
  sbd:
    device: {{ grains['sbd_disk_device'] }}
  join_timer: '20'
  {% if grains['provider'] == 'libvirt' %}
  ntp: pool.ntp.org
  sshkeys:
    overwrite: true
    password: linux
  {% endif %}
  resource_agents:
    - SAPHanaSR

  {% if grains['init_type']|default('all') != 'skip-hana' %}
  configure:
    method: 'update'
    template:
      source: /srv/salt/hana/templates/performance_optimized.j2
      parameters:
        sid: {{ hana.hana.nodes[0].sid }}
        instance: {{ hana.hana.nodes[0].instance }}
        virtual_ip: 192.168.107.50
        virtual_ip_mask: 255.255.255.0
        platform: {{ grains['provider'] }}
        prefer_takeover: true
        auto_register: false
  {% endif %}
