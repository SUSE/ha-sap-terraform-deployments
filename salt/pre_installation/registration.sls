{% if grains['os_family'] == 'Suse' %}
{% if not grains.get('qa_mode') or '_node' not in grains.get('role') %}
{% if grains['reg_code'] %}
register_system:
  cmd.run:
    - name: /usr/bin/SUSEConnect -r $reg_code {{ ("-e " ~ grains['reg_email']) if grains['reg_email'] else "" }}
    - env:
        - reg_code: {{ grains['reg_code'] }}
    - retry:
        attempts: 3
        interval: 15
{% endif %}

{% if grains['reg_additional_modules'] %}
{% for module, mod_reg_code in grains['reg_additional_modules'].items() %}
{{ module }}_registration:
  cmd.run:
    - name: /usr/bin/SUSEConnect -p {{ module }} {{ "-r $mod_reg_code" if mod_reg_code else "" }}
    - env:
        - mod_reg_code: {{ mod_reg_code }}
    - retry:
        attempts: 3
        interval: 15
{% endfor %}
{% endif %}
{% endif %}
{% endif %}
