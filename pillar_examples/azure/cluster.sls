cluster:
  name: 'hacluster'
  init: 'hana01'
  interface: 'eth0'
  unicast: True
  watchdog:
    module: softdog
    device: /dev/watchdog
  sbd:
    device: '/dev/sdd'
  resource_agents:
    - SAPHanaSR
  configure:
    method: 'update'
    template:
      source: /srv/salt/hana/templates/scale_up_resources.j2 #This path changes beyond SLES15SP1
      parameters:
        sid: prd
        instance: 00
        virtual_ip: 10.74.1.5 # This value must match with the load balancer address: frontend_ip_configuration
        virtual_ip_mask: 24
        platform: azure
        prefer_takeover: true
        auto_register: false
