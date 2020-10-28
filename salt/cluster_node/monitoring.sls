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
        ARGS="--collector.systemd --no-collector.mdadm"
