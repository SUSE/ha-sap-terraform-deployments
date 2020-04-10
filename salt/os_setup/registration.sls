{% if grains['os_family'] == 'Suse' %}
{% if not grains.get('qa_mode') or '_node' not in grains.get('role') %}
{% if grains['reg_code'] %}
{% set mod_reg_code = grains['reg_code'] %}
register_system:
  cmd.run:
    - name: /usr/bin/SUSEConnect -r $reg_code {{ ("-e " ~ grains['reg_email']) if grains['reg_email'] else "" }}
    - env:
        - reg_code: {{ grains['reg_code'] }}
    - retry:
        attempts: 3
        interval: 15
{% endif %}


{% if not 'iscsi_srv' in grains.get('role') %}
{% if '12' in grains['osrelease'] %}
{% if grains['osrelease'] == '12' %}
default_sle_module_adv_systems_management_registration:
  cmd.run:
    - name: /usr/bin/SUSEConnect -p sle-module-adv-systems-management/{{ grains['osrelease'] }}/{{grains['osarch']}} {{ "-r $mod_reg_code" if mod_reg_code else "" }}
    - env:
        - mod_reg_code: {{ mod_reg_code }}
    - retry:
        attempts: 3
        interval: 15

default_sle_module_public_cloud_registration:
  cmd.run:
    - name: /usr/bin/SUSEConnect -p sle-module-public-cloud/{{ grains['osrelease'] }}/{{grains['osarch']}} {{ "-r $mod_reg_code" if mod_reg_code else "" }}
    - env:
        - mod_reg_code: {{ mod_reg_code }}
    - retry:
        attempts: 3
        interval: 15

# temporary PackageHub (temporarily for GCP until ECO-1148 is released)
default_PackageHub_registration_sle12:
  cmd.run:
     /usr/bin/SUSEConnect -p  PackageHub/{{ grains['osrelease'] }}/{{grains['osarch']}} {{ "-r $mod_reg_code" if mod_reg_code else "" }}
    - env:
        - mod_reg_code: {{ mod_reg_code }}
    - retry:
        attempts: 3
        interval: 15

{% endif %}
{% endif %}

# sle15 
# temporary PackageHub (temporarily for GCP until ECO-1148 is released)
{% if '15' in grains['osrelease'] %}
{% if grains['osrelease'] == '15' %}
default_PackageHub_registration_sle15:
  cmd.run:
    - name: /usr/bin/SUSEConnect -p  PackageHub/{{ grains['osrelease'] }}/{{grains['osarch']}} {{ "-r $mod_reg_code" if mod_reg_code else "" }}
    - env:
        - mod_reg_code: {{ mod_reg_code }}
    - retry:
        attempts: 3
        interval: 15
{% endif %}
{% endif %}
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
