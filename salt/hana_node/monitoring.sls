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

prometheus_ha_cluster_exporter:
  pkg.installed:
    - name: prometheus-ha_cluster_exporter
    - require:
      - pkgrepo: server_monitoring_repo

ha_cluster_exporter_service:
  service.running:
    - name: prometheus-ha_cluster_exporter
    - enable: True
    - restart: True
    - require:
      - pkg: prometheus_ha_cluster_exporter
      - pkgrepo: server_monitoring_repo
