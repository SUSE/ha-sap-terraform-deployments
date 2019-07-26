server_monitoring_repo:
 pkgrepo.managed:
    - humanname: Server:SLE15:Monitoring
    - baseurl: https://download.opensuse.org/repositories/server:/monitoring/SLE_15/
    - refresh: True
    - gpgautoimport: True

sle_15_update:
 pkgrepo.managed:
    - humanname: SLE15:Update
    - baseurl: http://download.suse.de/ibs/SUSE/Updates/SLE-Module-Basesystem/15/x86_64/update/
    - refresh: True
    - gpgautoimport: True

sle_15_pool:
 pkgrepo.managed:
    - humanname: SLE15:Pool
    - baseurl: http://download.suse.de/ibs/SUSE/Products/SLE-Module-Basesystem/15/x86_64/product/
    - refresh: True
    - gpgautoimport: True

prometheus_node_exporter:
  pkg.installed:
    - name: golang-github-prometheus-node_exporter
    - require:
      - pkgrepo: server_monitoring_repo
      - pkgrepo: sle_15_update
      - pkgrepo: sle_15_pool

node_exporter_service:
  service.running:
    - name: prometheus-node_exporter
    - enable: True
    - restart: True
    - require:
      - pkg: prometheus_node_exporter
      - pkgrepo: server_monitoring_repo
      - pkgrepo: sle_15_update
      - pkgrepo: sle_15_pool

