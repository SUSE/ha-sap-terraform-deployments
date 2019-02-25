# -*- coding: utf-8 -*-
# vim: ft=sls
{%- from "iscsi/map.jinja" import iscsi with context %}

iscsi_isns_service_name_stop:
  service.dead:
    - name: {{ iscsi.isns.isnsd.man5.svcname }}
    - enable: False
    - sig: {{ iscsi.isns.isnsd.man5.svcname }}

iscsi_isns_service_config_backup:
  file.copy:
    - name: {{ iscsi.isns.isnsd.man5.config }}.bak
    - source: {{ iscsi.isns.isnsd.man5.config }}
    - force: True

iscsi_isns_service_config_removed:
  file.absent:
    - name: {{ iscsi.isns.isnsd.man5.config }}
    - require:
      - service: iscsi_isns_service_name_stop
      - file: iscsi_isns_service_config_backup

  {%- for pkg in [iscsi.isns.pkgs.wanted, iscsi.isns.pkgs.unwanted] %}
iscsi_isns_remove_{{ pkg }}_pkg:
  pkg.purged:
    - pkg: {{ pkg }}
    - require:
      - service: iscsi_isns_service_config_removed
  {% endfor %}

