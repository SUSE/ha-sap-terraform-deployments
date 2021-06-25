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
  join_timeout: 180
  {% if grains['fencing_mechanism'] == 'sbd' %}
  sbd:
    device: {{ grains['sbd_disk_device']|default('') }}
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
    method: 'update'
    template:
      source: salt://drbd/templates/habootstrap-formula/cluster_resources_nfs_cloud.j2
      parameters:
        {% if grains['provider'] == 'aws' %}
        virtual_ip: {{ grains['drbd_cluster_vip'] }}
        route_table: {{ grains['route_table'] }}
        cluster_profile: {{ grains['aws_cluster_profile'] }}
        instance_tag: {{ grains['aws_instance_tag'] }}
        {% elif grains['provider']== "azure" %}
        probe: 61000
        {% elif grains['provider'] == 'gcp' %}
        virtual_ip: {{ grains['drbd_cluster_vip'] }}
        vpc_network_name: {{ grains['vpc_network_name'] }}
        route_name: {{ grains['route_name'] }}
        {% elif grains['provider'] == 'openstack' %}
        virtual_ip: {{ grains['drbd_cluster_vip'] }}
        virtual_ip_mask: 24
        {% endif %}
        native_fencing: {{ grains['fencing_mechanism'] == 'native' }}
