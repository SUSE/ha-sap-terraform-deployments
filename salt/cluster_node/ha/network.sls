# This state would be better in habootstrap-formula
{% if grains['provider'] == 'aws' %}
cloud-netconfig-ec2:
  pkg.installed:
    - retry:
        attempts: 3
        interval: 15
{% elif grains['provider'] == 'azure' %}
cloud-netconfig-azure:
  pkg.installed:
    - retry:
        attempts: 3
        interval: 15
{% endif %}

# Add workaround: https://www.suse.com/support/kb/doc/?id=7023633
/etc/sysconfig/network/ifcfg-eth0:
  file.replace:
    - pattern: '^CLOUD_NETCONFIG_MANAGE.*'
    - repl: "CLOUD_NETCONFIG_MANAGE='no'"
    {% if grains['provider'] != 'libvirt' %}
    - append_if_not_found: True
    {% endif %}

network:
  service.running:
    - watch:
      - file: /etc/sysconfig/network/ifcfg-eth0
