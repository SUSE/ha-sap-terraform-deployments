# TODO: this repo should detect the os itself and chooose right repo depending the os
# for moment ok
server_monitoring_repo:
 pkgrepo.managed:
    - humanname: Server:SLE15:Monitoring
    - baseurl: https://download.opensuse.org/repositories/server:/monitoring/SLE_15/
    - refresh: True
    - gpgautoimport: True

prometheus:
  pkg.installed:
    - name: golang-github-prometheus-prometheus
    - require:
      - pkgrepo: server_monitoring_repo

prometheus_shap_configuration:
  file.recurse:
    - name: /etc/prometheus/
    - makedirs: True
    - source: salt://monitoring/prometheus
    - template: jinja
    - include_empty: True

prometheus_service:
  service.running:
    - name: prometheus
    - enable: True
    - require:
      - file: prometheus_shap_configuration
    - watch:
      - file: prometheus_shap_configuration

grafana:
  pkg.installed:
    - name: grafana
    - require:
      - pkgrepo: server_monitoring_repo

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
      - pkg: grafana

grafana_port_configuration:
  file.replace:
    - name: /etc/grafana/grafana.ini
    - pattern: ;http_port = 3000
    - repl: http_port = 80
    - require:
      - pkg: grafana

grafana_provisioning_directory:
  file.recurse:
    - name: /etc/grafana/provisioning
    - source: salt://monitoring/provisioning
    - clean: True
    - user: grafana
    - group: grafana
    - require:
      - pkg: grafana

grafana_service_configuration:
  file.replace:
    - name: /usr/lib/systemd/system/grafana-server.service
    - pattern: (User|Group)=grafana
    - repl: '#\1'
    - require:
      - pkg: grafana

grafana_service:
  service.running:
    - name: grafana-server
    - enable: True
    - restart: True
    - require:
      - pkg: grafana
      - file: grafana_port_configuration
      - file: grafana_provisioning_directory
      - file: grafana_service_configuration
    - watch:
      - file: grafana_port_configuration
      - file: grafana_provisioning_directory
      - file: grafana_service_configuration

prometheus-alertmanager:
  pkg.installed:
    - names:
      - golang-github-prometheus-alertmanager
    - enable: True
    - reload: True
    - require:
      - service: prometheus_service
      - file: prometheus_shap_configuration
    - watch:
      - file: prometheus_shap_configuration
