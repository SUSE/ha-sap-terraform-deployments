prometheus_node_exporter:
  pkg.installed:
    - name: golang-github-prometheus-node_exporter

node_exporter_service:
  service.running:
    - name: prometheus-node_exporter
    - enable: True
    - restart: True
    - require:
      - pkg: prometheus_node_exporter
      - file: activate_node_exporter_systemd_collector
    - watch:
      - file: activate_node_exporter_systemd_collector

activate_node_exporter_systemd_collector:
  file.managed:
    - name: /etc/sysconfig/prometheus-node_exporter
    - makedirs: True
    - contents: |
        ARGS="--collector.systemd"

loki:
  pkg.installed:
    - name: loki
    - retry:
        attempts: 3
        interval: 15

promtail_config:
  file.managed:
    - name: /etc/loki/promtail.yaml
    - template: jinja
    - source: salt://cluster_node/templates/promtail.yaml.j2

promtail_service:
  service.running:
    - name: promtail
    - enable: True
    - restart: True
    - require:
      - pkg: loki
      - file: promtail_config
