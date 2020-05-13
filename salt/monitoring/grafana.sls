grafana:
  pkg.installed:
    - name: grafana
    - require:
      - pkgrepo: server_monitoring_repo
    - retry:
        attempts: 3
        interval: 15

grafana_anonymous_login_configuration:
  file.blockreplace:
    - name: /etc/grafana/grafana.ini
    - marker_start: '#################################### Anonymous Auth ######################'
    - marker_end: '#################################### Github Auth ##########################'
    - content: |
        [auth.anonymous]
        enabled = true
        org_name = Main Org.
        org_role = Admin
    - require:
      - grafana

grafana_port_configuration:
  file.replace:
    - name: /etc/grafana/grafana.ini
    - pattern: ;http_port = 3000
    - repl: http_port = 80
    - require:
      - grafana

grafana_provisioning:
  file.recurse:
    - name: /etc/grafana/provisioning
    - source: salt://monitoring/grafana/provisioning
    - clean: True
    - user: grafana
    - group: grafana
    - require:
      - grafana

grafana_provisioning_datasources:
  file.managed:
    - name:  /etc/grafana/provisioning/datasources/datasources.yml
    - source: salt://monitoring/grafana/datasources.yml.j2
    - template: jinja
    - makeDirs: true
    - require:
      - grafana
      - grafana_provisioning

grafana_service:
  service.running:
    - name: grafana-server
    - enable: True
    - restart: True
    - require:
      - grafana
      - grafana_port_configuration
      - grafana_anonymous_login_configuration
      - grafana_provisioning
      - grafana_provisioning_datasources
