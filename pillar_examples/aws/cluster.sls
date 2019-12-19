cluster:
  name: 'hana_cluster'
  init: 'hana01'
  interface: 'eth0'
  unicast: True
  watchdog:
    module: softdog
    device: /dev/watchdog
  sbd:
    device: '/dev/sda'
  ntp: pool.ntp.org
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
        virtual_ip: 10.0.1.50
        virtual_ip_mask: 16
        prefer_takeover: true
        auto_register: false
