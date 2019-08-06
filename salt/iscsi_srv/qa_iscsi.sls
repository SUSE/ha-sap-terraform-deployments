{% if grains.get('qa_mode') %}
/etc/target/saveconfig.json:
  file.managed:
    - source: salt://iscsi_srv/files/qa_conf/saveconfig.json
    - user: root
    - group: root
    - mode: 600
    - template: jinja

restart_targetcli:
  service.running:
    - name: targetcli
    - enable: True
    - watch:
      - file: /etc/target/saveconfig.json
{% endif %}
