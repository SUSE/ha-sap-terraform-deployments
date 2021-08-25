{%- import_yaml "/srv/pillar/netweaver/netweaver.sls" as netweaver %}

cluster:
  install_packages: true
  name: netweaver_cluster
  init: {{ grains['name_prefix'] }}01
  {%- if grains['provider'] == 'libvirt' %}
  interface: eth1
  {%- else %}
  interface: eth0
  {%- endif %}
  unicast: True
  {% if grains['fencing_mechanism'] == 'sbd' %}
  sbd:
    device: {{ grains['sbd_disk_device']|default('') }}
  watchdog:
    module: softdog
    device: /dev/watchdog
  {% endif %}
  wait_for_initialization: 120
  {%- if grains['app_server_count']|default(2) == 0 %}
  # join_timeout must be large as the 1st machine where the cluster is started will host
  # the DB and PAS installation, taking a long time
  join_timeout: 10000
  {%- else %}
  join_timeout: 180
  {%- endif %}
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
    method: update
    template:
      source: salt://netweaver/templates/cluster_resources.j2
      parameters:
        sid: {{ netweaver.netweaver.nodes[0].sid }}
        ascs_instance: {{ grains['ascs_instance_number'] }}
        ers_instance: {{ grains['ers_instance_number'] }}
        {%- if grains['provider'] == 'libvirt' %}
        ascs_device: {{ netweaver.netweaver.nodes[0].shared_disk_dev }}2
        ascs_fstype: xfs
        ers_device: {{ netweaver.netweaver.nodes[1].shared_disk_dev }}3
        ers_fstype: xfs
        {%- elif grains['provider'] == 'azure' and grains['netweaver_shared_storage_type'] == 'anf' %}
        ascs_device: {{ grains['anf_mount_ip']['data'][0] }}:/netweaver-data/ASCS
        ascs_fstype: nfs4
        ers_device: {{ grains['anf_mount_ip']['data'][0] }}:/netweaver-data/ERS
        ers_fstype: nfs4
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
        ascs_route_name: {{ grains['ascs_route_name'] }}
        ers_route_name: {{ grains['ers_route_name'] }}
        vpc_network_name: {{ grains['vpc_network_name'] }}
        {%- endif %}
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
        sapmnt_path: {{ grains['netweaver_sapmnt_path'] }}
