# -*- coding: utf-8 -*-
# vim: ft=sls
{%- from "iscsi/map.jinja" import iscsi with context %}

  {%- set provider = iscsi.server.provider %}
  {%- set data = iscsi.target[provider|string] %}

  {%- if iscsi.server.pkgs.unwanted %}
    {%- for pkg in iscsi.server.pkgs.unwanted %}
iscsi_target_unwanted_pkgs_{{ pkg }}:
  pkg.purged:
    - name: {{ pkg }}
    - require_in:
      - file: iscsi_target_service_config
    {% endfor %}
  {%- endif %}

  {%- if iscsi.server.pkgs.wanted %}
    {%- for pkg in iscsi.server.pkgs.wanted %}
iscsi_target_wanted_pkgs_{{ pkg }}:
  pkg.installed:
    - name: {{ pkg }}
    #- hold: {{ iscsi.server.pkghold }}
    - reload: True
    - require_in:
      - file: iscsi_target_service_config
    {% endfor %}
  {%- endif %}

{%-if iscsi.server.make.wanted and salt['cmd.run']("id iscsi.user", output_loglevel='quiet')%}
  {%- for pkg in iscsi.server.make.wanted %}
iscsi_target_make_pkg_{{ pkg }}:
  file.directory:
    - name: /home/{{ iscsi.user }}
    - makedirs: True
    - user: {{ iscsi.user }}
    - dir_mode: '0755'
      {%- if iscsi.server.make.gitrepo %}
  git.latest:
    - name: {{ iscsi.server.make.gitrepo }}/{{ pkg }}.git
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
      - file: iscsi_target_make_pkg_{{ pkg }}
      {%- endif %}
  cmd.run:
    - cwd: /home/{{ iscsi.user }}/{{ pkg }}
    - name: {{ iscsi.server.make.cmd }}
    - runas: {{ iscsi.user }}
  {% endfor %}
{%- endif %}

iscsi_target_service_config:
  file.managed:
    - name: {{ data.man5.config }}
    - source: {{ iscsi.cfgsource }}
    - template: jinja
    - user: root
    - group: {{ iscsi.group }}
    - mode: {{ iscsi.filemode }}
    - makedirs: True
    - context:
        data: {{ data|json }}
        component: 'target'
        provider: {{ provider }}
        json: {{ data['man5']['format']['json'] }}

  {%- if iscsi.kernel.mess_with_kernel and data.man5.kmodule and data.man5.kloadtext %}
iscsi_target_kernel_module:
  file.line:
    - name: {{ iscsi.kernel.modloadfile }}
    - content: {{ data.man5.kloadtext }}
    - backup: True
        {%- if not data.enabled %}
    - mode: delete
  cmd.run:
    - name: {{ data.kernel.modunload }}
    - onlyif: {{ data.kernel.modquery }}
        {%- else %}
    - mode: ensure
    - after: 'autoboot_delay.*'
  cmd.run:
    - name: {{ data.kernel.modload }}
    - unless: {{ data.kernel.modquery }}
    - require:
      - file: iscsi_target_kernel_module
        {%- endif %}
    - require_in:
      - service: iscsi_target_service_running
  {%- endif %}

  {%- if grains.os == 'FreeBSD' %}
iscsi_target_service_freebsd_support:
  file.line:
    - name: {{ data.man5.svcloadfile }}
    - content: 'ctld_env="-u"'
    - backup: True
        {%- if not iscsi.server.enabled %}
    - mode: delete
        {%- else %}
    - mode: ensure
    - after: 'sshd_enable.*'
        {%- endif %}
  {%- endif %}

iscsi_target_service_running:
        {%- if not iscsi.server.enabled %}
  service.disabled:
    - enable: False
        {%- else %}
  service.running:
    - enable: True
    - require:
      - file: iscsi_target_service_config
    - watch:
      - file: iscsi_target_service_config
        {%- endif %}
    - name: {{ data.man5.svcname }}
  {%- if data.man5.kmodule %}
    - unless: {{ iscsi.kernel.modquery }} {{ data.man5.kmodule }}
  {%- endif %}

targetcli:
 service.running:
   - enable: True
   - watch:
     - file: /etc/target/saveconfig.json
