cluster:
  install_packages: true
  name: 'drbd_cluster'
  init: {{ grains['name_prefix'] }}01
  interface: eth0

  unicast: True
  join_timer: 20
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

  configure:
    method: 'update'
    template:
      source: /srv/salt/drbd_files/templates/drbd_cluster.j2
      parameters:
        virtual_ip: {{ ".".join(grains['host_ip'].split('.')[0:-1]) }}.200
        virtual_ip_mask: 24
        platform: libvirt
