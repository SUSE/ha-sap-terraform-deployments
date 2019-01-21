ntp_packages:
  pkg.installed:
  - name: ntp

/etc/ntp.conf:
  file.append:
  - text:
    - server {{ grains['ntp_server'] }}

ntpd:
  service.running:
  - enable: True
  - watch:
    - file: /etc/ntp.conf
