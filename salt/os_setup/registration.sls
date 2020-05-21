{% if grains['os_family'] == 'Suse' %}
{% if not grains.get('qa_mode') or '_node' not in grains.get('role') %}
{% if grains['reg_code'] %}
{% set reg_code = grains['reg_code'] %}
{% set arch = grains['osarch'] %}
register_system:
  cmd.run:
    - name: /usr/bin/SUSEConnect -r $reg_code {{ ("-e " ~ grains['reg_email']) if grains['reg_email'] else "" }}
    - env:
        - reg_code: {{ reg_code }}
    - retry:
        attempts: 3
        interval: 15
{% endif %}


{% if grains['osmajorrelease'] == 12 %}
# hardcode the 12 version number for the 2 following modules, since they don't offer a sp version only 1.
default_sle_module_adv_systems_management_registration:
  cmd.run:
    - name: /usr/bin/SUSEConnect -p sle-module-adv-systems-management/12/{{ arch }} -r $reg_code
    - env:
        - reg_code: {{ reg_code }}
    - retry:
        attempts: 3
        interval: 15

{%- if grains['provider'] in ['gcp', 'aws', 'azure'] %}
default_sle_module_public_cloud_registration:
  cmd.run:
    - name: /usr/bin/SUSEConnect -p sle-module-public-cloud/12/{{ arch }} -r $reg_code
    - env:
        - reg_code: {{ reg_code }}
    - retry:
        attempts: 3
        interval: 15

{% endif %}

{% elif grains['osmajorrelease'] == 15 and grains['provider'] in ['gcp', 'aws', 'azure'] %}
default_sle_module_public_cloud_registration:
  cmd.run:
    - name: /usr/bin/SUSEConnect -p sle-module-public-cloud/{{ grains['osrelease'] }}/{{ arch }} -r $reg_code
    - env:
        - reg_code: {{ reg_code }}
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
