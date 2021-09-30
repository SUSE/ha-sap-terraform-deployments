{% import_yaml "/srv/pillar/hana/hana.sls" as hana %}

cluster:
  {% if grains.get('offline_mode') %}
  install_packages: false
  {% endif %}
  name: hana_cluster
  init: {{ grains['name_prefix'] }}01
  {% if grains['provider'] == 'libvirt' %}
  interface: eth1
  {% else %}
  interface: eth0
  {% endif %}
  wait_for_initialization: 120
  unicast: True
  join_timeout: 500
  {% if grains['fencing_mechanism'] == 'sbd' %}
  sbd:
    device: {{ grains['sbd_disk_device']|default('') }}
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
  {% elif grains['provider'] == 'gcp' %}
  corosync:
    totem:
      secauth: 'off'
      token: 20000
      consensus: 24000
  {% endif %}
  monitoring_enabled: {{ grains['monitoring_enabled']|default(False) }}
  configure:
    properties:
      stonith-enabled: true
      {% if grains['provider'] == 'azure' %}
      stonith-timeout: 144s
      {% endif %}
    template:
      source: salt://hana/templates/scale_up_resources.j2
      parameters:
        sid: {{ hana.hana.nodes[0].sid }}
        instance: {{ hana.hana.nodes[0].instance }}
        {% if grains['provider'] == 'aws' %}
        route_table: {{ grains['route_table'] }}
        cluster_profile: {{ grains['aws_cluster_profile'] }}
        instance_tag: {{ grains['aws_instance_tag'] }}
        {% elif grains['provider'] == 'gcp' %}
        virtual_ip_mechanism: {{ grains['hana_cluster_vip_mechanism'] }}
        {% if grains['hana_cluster_vip_mechanism'] == 'route' %}
        vpc_network_name: {{ grains['vpc_network_name'] }}
        route_name: {{ grains['route_name'] }}
        route_name_secondary: {{ grains['route_name_secondary'] }}
        {% endif %}
        {% endif %}
        virtual_ip: {{ grains['hana_cluster_vip'] }}
        {% if grains['provider'] == 'gcp' %}
        virtual_ip_mask: 32
        {% else %}
        virtual_ip_mask: 24
        {% endif %}
        {% if grains['hana_cluster_vip_secondary'] %}
        virtual_ip_secondary: {{ grains['hana_cluster_vip_secondary'] }}
        {% endif %}
        native_fencing: {{ grains['fencing_mechanism'] == 'native' }}
        {% if grains['fencing_mechanism'] == 'native' %}
        {% if grains['provider'] == 'azure' %}
        # only used by azure fence agent (native fencing)
        azure_subscription_id: {{ grains['subscription_id'] }}
        azure_resource_group_name: {{ grains['resource_group_name'] }}
        azure_tenant_id: {{ grains['tenant_id'] }}
        azure_fence_agent_app_id: {{ grains['fence_agent_app_id'] }}
        azure_fence_agent_client_secret: {{ grains['fence_agent_client_secret'] }}
        {% endif %}
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
