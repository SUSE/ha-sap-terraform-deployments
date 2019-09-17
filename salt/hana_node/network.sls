/etc/sysconfig/network/ifcfg-eth0:
  file.replace:
    - pattern: '^CLOUD_NETCONFIG_MANAGE.*'
    - repl: 'CLOUD_NETCONFIG_MANAGE=no'

network:
  service.running:
    - enable: True
    - watch:
      - file: /etc/sysconfig/network/ifcfg-eth0
