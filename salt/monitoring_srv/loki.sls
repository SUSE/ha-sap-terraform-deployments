{# loki package is currently disabled. To use it, add the .loki sls entry in init.sls and enable loki as datasource in grafana/datasources template #}
loki:
  pkg.installed:
    - name: loki
    - retry:
        attempts: 3
        interval: 15

loki_service:
  service.running:
    - name: loki
    - enable: True
    - restart: True
    - require:
      - pkg: loki
