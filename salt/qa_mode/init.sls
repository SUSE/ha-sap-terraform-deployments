{% if grains.get('hwcct') == true and 'hana01' in grains['hostname'] %}
hwcct-config-file:
  file.managed:
    - template: jinja
    - names:
      - /srv/salt/qa_mode/files/hwcct/hwcct_config.json:
        - source: salt://qa_mode/files/hwcct/hwcct_config.json.jinja

hwcct-bench-file:
  file.managed:
    - template: jinja
    - names:
      - /srv/salt/qa_mode/files/hwcct/hwcct_bench.sh:
        - source: salt://qa_mode/files/hwcct/hwcct_bench.jinja

hwcct:
  cmd.run:
    - name: sh /srv/salt/qa_mode/files/hwcct/hwcct_bench.sh
    - require:
      - file: hwcct-config-file
      - file: hwcct-bench-file
{% else %}
# Do nothing if 'hwcct=false'
default_nop:
  test.nop: []
{% endif %}
