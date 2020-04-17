{% set repository = 'SLE_'~grains['osrelease_info'][0] %}
{% set repository = repository~'_SP'~grains['osrelease_info'][1] if grains['osrelease_info']|length > 1 else repository %}

server_monitoring_repo:
 pkgrepo.managed:
    - humanname: Server:Monitoring
    - baseurl: https://download.opensuse.org/repositories/server:/monitoring/{{ repository }}/
    - refresh: True
    - gpgautoimport: True
    - retry:
        attempts: 3
        interval: 15

prometheus:
  pkg.installed:
    - name: golang-github-prometheus-prometheus
    - require:
      - pkgrepo: server_monitoring_repo
    - retry:
        attempts: 3
        interval: 15

prometheus_alerts:
  file.managed:
    - name:  /etc/prometheus/rules.yml
    - source: salt://monitoring/prometheus/rules.yml
    - require:
      - pkg: prometheus

prometheus_configuration:
  file.managed:
    - name:  /etc/prometheus/prometheus.yml
    - source: salt://monitoring/prometheus/prometheus.yml.j2
    - template: jinja
    - require:
      - pkg: prometheus

prometheus_service:
  service.running:
    - name: prometheus
    - enable: True
    - require:
      - file: prometheus_configuration
      - file: prometheus_alerts
    - watch:
      - file: prometheus_configuration
      - file: prometheus_alerts

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
      - file: prometheus_configuration
      - file: prometheus_alerts
    - watch:
      - file: prometheus_configuration
      - file: prometheus_alerts
    - retry:
        attempts: 3
        interval: 15
