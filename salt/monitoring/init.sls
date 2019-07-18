# TODO: this repo should detect the os itself and chooose right repo depending the os
repos:
 pkgrepo.managed:
    - humanname: devel:tools
    - baseurl: http://download.suse.de/ibs/Devel:/Galaxy:/Manager:/Head:/SLE15-SUSE-Manager-Tools/SLE_15/
    - refresh: True
    - gpgautoimport: True


prometheus:
  pkg.installed:
    - name: golang-github-prometheus-prometheus
    - require:
      - pkgrepo: repos

prometheus_configuration:
  file.managed:
    - name: /etc/prometheus/prometheus.yml
    - makedirs: True
    - contents: |
        scrape_configs:
          - job_name: 'sumaform'
            scrape_interval: 5s
            static_configs:
         ## TODO: grains server need to be passed to monitoring module , change localhost
              - targets: [localhost:8001'] # hanadb_exporter
          - job_name: 'hanadb'
            scrape_interval: 5s
            static_configs:
         ## TODO: change localhost  with grain
              - targets: ['localhost:9800']

prometheus_service:
  file.managed:
    - name: /etc/systemd/system/prometheus.service
    - contents: |
        [Unit]
        Description=prometheus

        [Service]
        ExecStart=/usr/bin/prometheus --config.file=/etc/prometheus/prometheus.yml

        [Install]
        WantedBy=multi-user.target
    - require:
      - pkg: prometheus
  service.running:
    - name: prometheus
    - enable: True
    - require:
      - file: prometheus_service
      - file: prometheus_configuration
    - watch:
      - file: prometheus_configuration

grafana:
  pkg.installed:
    - name: grafana
    - require:
      - pkgrepo: repos

grafana_anonymous_login_configuration:
  file.blockreplace:
    - name: /etc/grafana/grafana.ini
    - marker_start: '#################################### Anonymous Auth ##########################'
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
    - source: salt://grafana/provisioning
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

grafana_setup:
  cmd.script:
    - name: salt://grafana/setup_grafana.py
    - require:
      - service: grafana_service
