cluster:
  name: 'drbd_cluster'
  init: '<HOSTNAME_1>'
  interface: 'eth0'
  join_timer: 20
  watchdog:
    module: softdog
    device: /dev/watchdog
  sbd:
    device: '<SBD_DEVICE>'
  ntp: pool.ntp.org
  install_packages: true
  sshkeys:
    overwrite: true
    password: linux
  configure:
    method: 'update'
    template:
      source: /srv/salt/drbd_files/templates/drbd_cluster.j2
      parameters:
        virtual_ip: <ADMIN_VIRTUAL_IP>
        virtual_ip_mask: 24
        platform: libvirt
