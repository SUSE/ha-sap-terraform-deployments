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
