server_monitoring_repo:
 pkgrepo.managed:
    - humanname: Server:SLE15:Monitoring
    - baseurl: https://download.opensuse.org/repositories/server:/monitoring/SLE_15/
    - refresh: True
    - gpgautoimport: True

prometheus_node_exporter:
  pkg.installed:
    - name: golang-github-prometheus-node_exporter
    - require:
      - pkgrepo: server_monitoring_repo

node_exporter_service:
  service.running:
    - name: prometheus-node_exporter
    - enable: True
    - restart: True
    - require:
      - pkg: prometheus_node_exporter
      - pkgrepo: server_monitoring_repo
      - file: activate_node_exporter_systemd_collector
    - watch:
      - file: activate_node_exporter_systemd_collector

activate_node_exporter_systemd_collector:
  file.managed:
    - name: /etc/sysconfig/prometheus-node_exporter
    - makedirs: True
    - contents: |
        ARGS="--collector.systemd"
