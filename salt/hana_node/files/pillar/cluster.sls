cluster:
  name: 'hacluster'
  init: 'hana01'
  interface: 'eth1'
  watchdog:
    module: 'softdog'
    device: '/dev/watchdog'
  sbd:
    device: '/dev/vdc'
  join_timer: '20'
{% if grains['init_type']|default('all') != 'skip-hana' %}
  configure:
    method: 'update'
    url: '/tmp/cluster.config'
{% endif %}
  # This next options only are used to update the cluster.j2 template file.
  # virtual_ip is used to avoid the creation of the RA in "cluster init"
  # and create it when the file is imported (crm configure load)
  virtual_ip: '192.168.106.50'
  virtual_ip_mask: '255.255.255.0'
  platform: 'libvirt'
  prefer_takeover: 'true'
  auto_register: 'false'
