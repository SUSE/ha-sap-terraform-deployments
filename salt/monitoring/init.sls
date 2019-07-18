# TODO: this repo should detect the os itself and chooose right repo depending the os
# for moment ok
suse-manager-head-repo:
 pkgrepo.managed:
    - humanname: Head:SLE15:Manager:Tools
    - baseurl: http://download.suse.de/ibs/Devel:/Galaxy:/Manager:/Head:/SLE15-SUSE-Manager-Tools/SLE_15/
    - refresh: True
    - gpgautoimport: True

sle-15-update:
 pkgrepo.managed:
    - humanname: SLE15:Update
    - baseurl: http://download.suse.de/ibs/SUSE/Updates/SLE-Module-Basesystem/15/x86_64/update/
    - refresh: True
    - gpgautoimport: True

sle-15-pool:
 pkgrepo.managed:
    - humanname: SLE15:Pool
    - baseurl: http://download.suse.de/ibs/SUSE/Products/SLE-Module-Basesystem/15/x86_64/product/
    - refresh: True
    - gpgautoimport: True

prometheus:
  pkg.installed:
    - name: golang-github-prometheus-prometheus
    - require:
      - pkgrepo: suse-manager-head-repo
      - pkgrepo: sle-15-update
      - pkgrepo: sle-15-pool

prometheus_shap_configuration:
  file.managed:
    - name: /etc/prometheus/prometheus.yml
    - makedirs: True
    - contents: |
        scrape_configs:
          - job_name: 'handadb-metrics'
            scrape_interval: 5s
            static_configs:
         ## TODO: grains server need to be passed to monitoring module , change localhost
              - targets: [localhost:8001'] # hanadb_exporter

prometheus_service_systemd_activation:
  service.running:
    - name: prometheus
    - enable: True
    - require:
      - file: prometheus_configuration
    - watch:
      - file: prometheus_configuration

grafana:
  pkg.installed:
    - name: grafana
    - require:
      - pkgrepo: suse-manager-head-repo
      - pkgrepo: sle-15-update
      - pkgrepo: sle-15-pool

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
    - require:
      - pkg: grafana
      - file: grafana_port_configuration
      - file: grafana_provisioning_directory
      - file: grafana_service_configuration
    - watch:
      - file: grafana_port_configuration
      - file: grafana_provisioning_directory
      - file: grafana_service_configuration
