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

tuning_dashboard:
  file.managed:
    - name:  /var/lib/grafana/dashboards/sles4sap/tuning.json
    - source: salt://monitoring_srv/grafana/dashboards/tuning.json
    - user: grafana
    - group: grafana
    - require:
      - pkg: grafana


grafana_service:
  service.running:
    - name: grafana-server
    - enable: True
    - restart: True
    - require:
      - pkg: grafana
      - pkg: grafana_dashboards
      - file: grafana_anonymous_login_configuration
      - file: grafana_provisioning_datasources
