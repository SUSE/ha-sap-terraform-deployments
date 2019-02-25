#-*- coding: utf-8 -*-
# vim: ft=sls
{%- from "iscsi/map.jinja" import iscsi with context %}

  {%- set provider = iscsi.isns.provider %}
  {%- set data = iscsi.isns[provider|string] %}

  {%- if iscsi.isns.pkgs.unwanted %}
    {%- for pkg in iscsi.isns.pkgs.unwanted %}
iscsi_isnsd_remove_{{ pkg }}_pkg:
  pkg.purged:
    - name: {{ pkg }}
    - require_in:
      - file: iscsi_isnsd_service_config
    {% endfor %}
  {%- endif %}

  {%- if iscsi.isns.pkgs.wanted %}
    {%- for pkg in iscsi.isns.pkgs.wanted %}
iscsi_isnsd_install_{{ pkg }}_pkg:
  pkg.installed:
    - name: {{ pkg }}
    - hold: {{ iscsi.isns.pkghold }}
    - reload: True
    - require_in:
      - file: iscsi_isnsd_service_config
    {% endfor %}
  {%- endif %}

{%-if iscsi.isns.make.wanted and salt['cmd.run']("id iscsi.user", output_loglevel='quiet') %}
  {%- for pkg in iscsi.isns.make.wanted %}
iscsi_isns_make_pkg_{{ pkg }}:
  file.directory:
    - name: /home/{{ iscsi.user }}
    - makedirs: True
    - user: {{ iscsi.user }}
    - dir_mode: '0755'
    {%- if iscsi.isns.make.gitrepo %}
  git.latest:
    - name: {{ iscsi.isns.make.gitrepo }}/{{ pkg }}.git
    - target: /home/{{ iscsi.user }}/{{ pkg }}
    - user: {{ iscsi.user }}
    - force_clone: True
    - force_fetch: True
    - force_reset: True
    - force_checkout: True
    {% if grains['saltversioninfo'] >= [2017, 7, 0] %}
    - retry:
        attempts: 3
        until: True
        interval: 60
        splay: 10
    {%- endif %}
    - require:
      - file: iscsi_isns_make_pkg_{{ pkg }}
    {%- endif %}
  cmd.run:
    - cwd: /home/{{ iscsi.user }}/{{ pkg }}
    - name: {{ iscsi.isns.make.cmd }}
    - runas: {{ iscsi.user }}
  {% endfor %}
{%- endif %}

iscsi_isnsd_service_config:
  file.managed:
    - name: {{ data.man5.config }}
    - source: {{ iscsi.cfgsource }}
    - template: jinja
    - user: root
    - group: {{ iscsi.group }}
    - mode: {{ iscsi.filemode }}
    - makedirs: True
    - require_in:
    - service: iscsi_isnsd_service
    - test: True
    - context:
      data: {{ data|json }}
      component: 'isns'
      provider: {{ provider }}
      json: {{ data['man5']['format']['json'] }}

iscsi_isnsd_service:
       {%- if iscsi.isns.enabled %}
  service.running:
    - name: {{ data.man5.svcname }}
    - enable: True
    - watch:
      - file: iscsi_isnsd_service_config
      {%- else %}
  service.disabled:
    - name: {{ data.man5.svcname }}
    - enable: False
      {%- endif %}

