prometheus:
  pkg.installed:
    - name: golang-github-prometheus-prometheus
    - retry:
        attempts: 3
        interval: 15

prometheus_alerts:
  file.managed:
    - name:  /etc/prometheus/rules.yml
    - source: salt://monitoring_srv/prometheus/rules.yml
    - require:
      - pkg: prometheus

prometheus_configuration:
  file.managed:
    - name:  /etc/prometheus/prometheus.yml
    - source: salt://monitoring_srv/prometheus/prometheus.yml.j2
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
