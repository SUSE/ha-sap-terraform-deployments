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

# by default grafana will instruct browsers to not allow rendering Grafana in a <iframe>, set value to true
# this is needed in the blue-horizon static pages
grafana_allow_embedding:
  file.line:
    - name: /etc/grafana/grafana.ini
    - mode: ensure
    - after: \[security\]
    - content: allow_embedding = true
    - require:
      - pkg: grafana

# change theme to light for better matching blue-horizon colors ;default_theme = dark
grafana_default_color:
  file.line:
    - name: /etc/grafana/grafana.ini
    - mode: ensure
    - after: \[users\]
    - content: default_theme = light
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
