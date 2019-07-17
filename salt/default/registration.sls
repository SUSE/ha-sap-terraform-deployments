{% if grains['qa_mode']|default(false) is sameas false %}
{% if grains['reg_code'] %}
register_system:
  cmd.run:
    - name: /usr/bin/SUSEConnect -r {{ grains['reg_code'] }} {{ ("-e " ~ grains['reg_email']) if grains['reg_email'] else "" }}
    - retry:
        attempts: 3
        interval: 15
{% endif %}

{% if grains['reg_additional_modules'] %}
{% for module, mod_reg_code in grains['reg_additional_modules'].items() %}
{{ module }}_registration:
  cmd.run:
    - name: /usr/bin/SUSEConnect -p {{ module }} {{ ("-r " ~ mod_reg_code) if mod_reg_code else "" }}
    - retry:
        attempts: 3
        interval: 15
{% endfor %}
{% endif %}
{% endif %}
