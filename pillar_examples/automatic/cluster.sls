{% import_yaml "/root/salt/hana_node/files/pillar/hana.sls" as hana %}

cluster:
  {% if grains['qa_mode']|default(false) is sameas true %}
  install_packages: false
  {% endif %}
  name: hacluster
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
  resource_agents:
    - SAPHanaSR

  {% if grains['init_type']|default('all') != 'skip-hana' %}
  configure:
    method: update
    template:
      source: /srv/salt/hana/templates/performance_optimized.j2
      parameters:
        sid: {{ hana.hana.nodes[0].sid }}
        instance: {{ hana.hana.nodes[0].instance }}
        {% if grains['provider'] != 'azure' %}
        virtual_ip: {{ ".".join(grains['host_ips'][0].split('.')[0:-1]) }}.200
        {% else %}
        virtual_ip: {{ grains['azure_lb_ip'] }}
        {% endif %}
        {% if grains['provider'] == 'aws' %}
        virtual_ip_mask: 16
        {% else %}
        virtual_ip_mask: 24
        {% endif %}
        platform: {{ grains['provider'] }}
        prefer_takeover: true
        auto_register: false
  {% endif %}
