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


{% if '12' == grains['osmajorrelease'] %}
default_sle_module_adv_systems_management_registration:
  cmd.run:
    - name: /usr/bin/SUSEConnect -p sle-module-adv-systems-management/{{ grains['osrelease'] }}/{{ arch }} {{ "-r $reg_code" if reg_code else "" }}
    - env:
        - reg_code: {{ reg_code }}
    - retry:
        attempts: 3
        interval: 15

default_sle_module_public_cloud_registration:
  cmd.run:
    - name: /usr/bin/SUSEConnect -p sle-module-public-cloud/{{ grains['osrelease'] }}/{{ arch }} {{ "-r $reg_code" if reg_code else "" }}
    - env:
        - reg_code: {{ reg_code }}
    - retry:
        attempts: 3
        interval: 15

{% endif %}

# sle15 PackageHub (temporarily for GCP until ECO-1148 is released) and sle12 PackageHub (temporarily for GCP until ECO-1148 is released)
default_PackageHub_registration:
  cmd.run:
    - name: /usr/bin/SUSEConnect -p  PackageHub/{{ grains['osrelease'] }}/{{ arch }} {{ "-r $reg_code" if reg_code else "" }}
    - env:
        - reg_code: {{ reg_code }}
    - retry:
        attempts: 3
        interval: 15

{% if grains['reg_additional_modules'] %}
{% for module, reg_code in grains['reg_additional_modules'].items() %}
{{ module }}_registration:
  cmd.run:
    - name: /usr/bin/SUSEConnect -p {{ module }} {{ "-r $reg_code" if reg_code else "" }}
    - env:
        - reg_code: {{ reg_code }}
    - retry:
        attempts: 3
        interval: 15
{% endfor %}
{% endif %}
{% endif %}
{% endif %}
