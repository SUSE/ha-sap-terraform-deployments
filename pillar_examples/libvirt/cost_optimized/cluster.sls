cluster:
  name: 'hana_cluster'
  init: 'hana01'
  interface: 'eth1'
  watchdog:
    module: softdog
    device: /dev/watchdog
  sbd:
    device: '/dev/vdc'
  ntp: pool.ntp.org
  sshkeys:
    overwrite: true
    password: linux
  resource_agents:
    - SAPHanaSR
  ha_exporter: false
  configure:
    method: 'update'
    template:
      source: /usr/share/salt-formulas/states/hana/templates/scale_up_resources.j2
      parameters:
        sid: prd
        instance: "00"
        virtual_ip: 192.168.107.50
        virtual_ip_mask: 24
        platform: libvirt
        prefer_takeover: false
        auto_register: false
        cost_optimized_parameters:
          sid: qas
          instance: "01"
          remote_host : 'hana01'
