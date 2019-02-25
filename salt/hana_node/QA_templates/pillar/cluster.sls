cluster:
  install_packages: false
  name: 'hacluster'
  init: 'ip-10-0-1-0'
  interface: 'eth0'
  unicast: True
  watchdog: 
    module: softdog
    device: /dev/watchdog
  sbd:
    device: '/dev/sda'
  join_timer: '20'
{% if grains['init_type'] != 'skip-hana' %}
  configure:
    method: 'update'
    url: '/tmp/cluster.config'
{% endif %}
  # This next options only are used to update the cluster.j2 template file.
  # virtual_ip is used to avoid the creation of the RA in "cluster init"
  # and create it when the file is imported (crm configure load)
  virtual_ip: '10.0.0.250'
  virtual_ip_mask: '255.255.0.0'
  platform: 'libvirt'
  prefer_takeover: 'true'
  auto_register: 'false'

