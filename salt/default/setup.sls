minion_package:
  pkg.installed:
    - name: salt-minion
    - retry:
        attempts: 3
        interval: 15

minion_id:
  file.managed:
    - name: /etc/salt/minion_id
    - contents: {{ grains['hostname'] }}.{{ grains['domain'] }}

minion_service:
  service.running:
    - name: salt-minion
    - enable: True
    - require:
      - pkg: salt-minion
