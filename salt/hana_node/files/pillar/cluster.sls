cluster:
  name: 'hacluster'
  init: 'hana01'
  interface: 'eth1'
  watchdog: /dev/watchdog
  sbd:
    device: '/dev/vdc'
  configure:
    method: 'update'
    url: '/tmp/cluster.config'
  # This next options only are used to update the cluster.j2 template file.
  # admin_ip_x is used to avoid the creation of the RA in "cluster init"
  # and create it when the file is imported (crm configure load)
  admin_ip_x: '192.168.106.50'
  admin_ip_mask: '255.255.255.0'
  platform: 'libvirt'
  prefer_takeover: 'true'
  auto_register: 'true'
