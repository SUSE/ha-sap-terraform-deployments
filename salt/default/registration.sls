{% if grains['qa_mode']|default(false) is sameas false %}
{% if grains['reg_code'] %}
register_system:
  cmd.run:
    - name: /usr/bin/SUSEConnect -r {{ grains['reg_code'] }}  {{ ("-e " ~ grains['reg_email']) if grains['reg_email'] != None else "" }}
{% endif %}

{% if grains['reg_additional_modules'] %}
{% for module, mod_reg_code in grains['reg_additional_modules'].items() %}
{{ module }}_registration:
  cmd.run:
    - name: /usr/bin/SUSEConnect -p {{ module }}  {{ ("-r " ~ mod_reg_code) if mod_reg_code != None else "" }}
{% endfor %}
{% endif %}
{% endif %}
