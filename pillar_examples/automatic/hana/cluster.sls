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
  join_timeout: 180
  {% if grains['sbd_enabled'] %}
  sbd:
    device: {{ grains['sbd_disk_device'] }}
    {% if grains['provider'] == 'azure' %}
    configure_resource:
      params:
        pcmk_delay_max: 15
      op:
        monitor:
          timeout: 15
          interval: 15
    {% endif %}
  watchdog:
    module: softdog
    device: /dev/watchdog
  {% endif %}
  ntp: pool.ntp.org
  {% if grains['provider'] == 'libvirt' %}
  sshkeys:
    overwrite: true
    password: linux
  {% endif %}
  resource_agents:
    - SAPHanaSR
  {% if grains['provider'] == 'azure' %}
  corosync:
    totem:
      token: 30000
      token_retransmits_before_loss_const: 10
      join: 60
      consensus: 36000
      max_messages: 20
  {% endif %}
  monitoring_enabled: {{ grains['monitoring_enabled']|default(False) }}
  configure:
    {% if grains['provider'] == 'azure' %}
    properties:
      stonith-timeout: 144s
      stonith-enabled: true
    {% endif %}
    template:
      source: /usr/share/salt-formulas/states/hana/templates/scale_up_resources.j2
      parameters:
        sid: {{ hana.hana.nodes[0].sid }}
        instance: {{ hana.hana.nodes[0].instance }}
        {% if grains['provider'] == 'aws' %}
        route_table: {{ grains['route_table'] }}
        cluster_profile: {{ grains['aws_cluster_profile'] }}
        instance_tag: {{ grains['aws_instance_tag'] }}
        {% elif grains['provider'] == 'gcp' %}
        route_table: {{ grains['route_table'] }}
        vpc_network_name: {{ grains['vpc_network_name'] }}
        {% endif %}
        virtual_ip: {{ grains['hana_cluster_vip'] }}
        virtual_ip_mask: 24
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
