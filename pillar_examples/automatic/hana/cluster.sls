{% import_yaml "/root/salt/hana_node/files/pillar/hana.sls" as hana %}

cluster:
  {% if grains.get('qa_mode') %}
  install_packages: false
  {% endif %}
  name: hana_cluster
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
  ntp: pool.ntp.org
  {% if grains['provider'] == 'libvirt' %}
  sshkeys:
    overwrite: true
    password: linux
  {% endif %}
  resource_agents:
    - SAPHanaSR
  {% if grains.get('monitoring_enabled', False) %}
  ha_exporter: true
  {% else %}
  ha_exporter: false
  {% endif %}
  {% if grains['init_type']|default('all') != 'skip-hana' %}
  configure:
    method: update
    template:
      source: /usr/share/salt-formulas/states/hana/templates/scale_up_resources.j2
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
        {% if grains['scenario_type'] == 'cost-optimized' %}
        prefer_takeover: false
        {% else %}
        prefer_takeover: true
        {% endif %}
        auto_register: false
        {% if grains['scenario_type'] == 'cost-optimized' %}
        cost_optimized_parameters:
          sid: {{ hana.hana.nodes[2].sid }}
          instance: {{ hana.hana.nodes[2].instance }}
          remote_host : {{ hana.hana.nodes[0].host }}
        {% endif %}
  {% endif %}
