{%- import_yaml "/root/salt/netweaver_node/files/pillar/netweaver.sls" as netweaver %}
{%- if not grains.get('sbd_disk_device') %}
{%- set sbd_disk_device = salt['cmd.run']('lsscsi | grep "LIO-ORG" | awk "{ if (NR=='~grains['sbd_disk_index']~') print \$NF }"', python_shell=true) %}
{%- else %}
{%- set sbd_disk_device = grains['sbd_disk_device'] %}
{%- endif %}

cluster:
  install_packages: true
  name: netweaver_cluster
  init: {{ grains['name_prefix'] }}01
  {%- if grains['provider'] == 'libvirt' %}
  interface: eth1
  {%- else %}
  interface: eth0
  unicast: True
  {%- endif %}
  watchdog:
    module: softdog
    device: /dev/watchdog
  sbd:
    device: {{ sbd_disk_device }}
  join_timeout: 180
  wait_for_initialization: 20
  ntp: pool.ntp.org
  {%- if grains['provider'] == 'libvirt' %}
  sshkeys:
    overwrite: true
    password: linux
  {%- endif %}
  {% if grains['provider'] == 'azure' %}
  corosync:
    totem:
      token: 30000
      token_retransmits_before_loss_const: 10
      join: 60
      consensus: 36000
      max_messages: 20
  {% endif %}
  {%- for node in netweaver.netweaver.nodes if node.host == grains['host'] %}
  {%- if grains.get('monitoring_enabled', False) and node.sap_instance in ['ascs', 'ers'] %}
  ha_exporter: true
  {%- else %}
  ha_exporter: false
  {%- endif %}
  {%- endfor %}
  configure:
    method: update
    template:
      source: /usr/share/salt-formulas/states/netweaver/templates/cluster_resources.j2
      parameters:
        sid: {{ netweaver.netweaver.nodes[0].sid }}
        ascs_instance: {{ grains['ascs_instance_number'] }}
        ers_instance: {{ grains['ers_instance_number'] }}
        {%- if grains['provider'] == 'libvirt' %}
        ascs_device: {{ netweaver.netweaver.nodes[0].shared_disk_dev }}2
        ascs_fstype: xfs
        ers_device: {{ netweaver.netweaver.nodes[1].shared_disk_dev }}3
        ers_fstype: xfs
        {%- else %}
        ascs_device: {{ grains['netweaver_nfs_share'] }}/ASCS
        ascs_fstype: nfs4
        ers_device: {{ grains['netweaver_nfs_share'] }}/ERS
        ers_fstype: nfs4
        {%- endif %}
        ascs_ip_address: {{ grains['virtual_host_ips'][0] }}
        ers_ip_address: {{ grains['virtual_host_ips'][1] }}
        ascs_virtual_host: {{ netweaver.netweaver.nodes[0].virtual_host }}
        ers_virtual_host: {{ netweaver.netweaver.nodes[1].virtual_host }}
        {%- if grains['provider'] == 'aws' %}
        route_table: {{ grains['route_table'] }}
        cluster_profile: {{ grains['aws_cluster_profile'] }}
        instance_tag: {{ grains['aws_instance_tag'] }}
        {%- elif grains['provider'] == 'gcp' %}
        route_table: {{ grains['route_table'] }}
        vpc_network_name: {{ grains['vpc_network_name'] }}
        {%- endif %}
        monitoring_enabled: {{ grains['monitoring_enabled']|default(False) }}
