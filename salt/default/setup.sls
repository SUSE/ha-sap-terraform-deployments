minion_package:
  pkg.installed:
    - name: salt-minion
    - retry:
        attempts: 3
        interval: 15

minion_id:
  file.managed:
    - name: /etc/salt/minion_id
    - contents: {{ grains['hostname'] }}.{{ grains['network_domain'] }}

minion_service:
  service.dead:
    - name: salt-minion
    - enable: False
    - require:
      - pkg: salt-minion
