# Add workaround: https://www.suse.com/support/kb/doc/?id=7023633

/etc/sysconfig/network/ifcfg-eth0:
  file.replace:
    - pattern: '^CLOUD_NETCONFIG_MANAGE.*'
    - repl: 'CLOUD_NETCONFIG_MANAGE=no'

network:
  service.running:
    - enable: True
    - watch:
      - file: /etc/sysconfig/network/ifcfg-eth0
