grafana:
  pkg.installed:
    - name: grafana
    - retry:
        attempts: 3
        interval: 15

grafana_anonymous_login_configuration:
  file.line:
    - name: /etc/grafana/grafana.ini
    - mode: ensure
    - after: \[auth\.anonymous\]
    - content: enabled = true
    - require:
      - pkg: grafana

grafana_provisioning_datasources:
  file.managed:
    - name:  /etc/grafana/provisioning/datasources/datasources.yml
    - source: salt://monitoring_srv/grafana/datasources.yml.j2
    - template: jinja
    - makedirs: True
    - user: grafana
    - group: grafana
    - require:
      - pkg: grafana

grafana_dashboards:
  pkg.installed:
    - pkgs:
      - grafana-ha-cluster-dashboards
      - grafana-sap-hana-dashboards
      - grafana-sap-netweaver-dashboards

grafana_service:
  service.running:
    - name: grafana-server
    - enable: True
    - require:
      - pkg: grafana
      - pkg: grafana_dashboards
      - file: grafana_anonymous_login_configuration
      - file: grafana_provisioning_datasources
