prometheus_saptune_exporter:
  pkg.installed:
    - name: prometheus-saptune_exporter

saptune_exporter_service:
  service.running:
    - name: prometheus-saptune_exporter
    - enable: True
    - restart: True
    - require:
      - pkg: prometheus-saptune_exporter
