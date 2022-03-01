prometheus_node_exporter:
  pkg.installed:
    - name: golang-github-prometheus-node_exporter

node_exporter_service:
  service.running:
    - name: prometheus-node_exporter
    - enable: True
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

{%- if grains['osmajorrelease'] > 12 %}
promtail:
  pkg.installed:
    - name: promtail
    - retry:
        attempts: 3
        interval: 15

promtail_config:
  file.managed:
    - name: /etc/loki/promtail.yaml
    - template: jinja
    - source: salt://cluster_node/templates/promtail.yaml.j2

# we need to add loki's user to the systemd-journal group, to let promtail read /run/log/journal
## https://build.opensuse.org/request/show/940653 removed the loki user
## promtail is running as root now and loki's permissions do not need to be adapted for now
# loki_systemd_journal_member:
#   group.present:
#     - name: systemd-journal
#     - addusers:
#       - loki
#     - require:
#       - pkg: promtail

promtail_service:
  service.running:
    - name: promtail
    - enable: True
    - require:
      - pkg: promtail
      - file: promtail_config
#      - group: loki_systemd_journal_member
{%- endif %}
