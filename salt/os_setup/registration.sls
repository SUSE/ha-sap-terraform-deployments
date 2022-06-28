{% if grains['osfullname'] == 'SLES' %}

{% if grains['reg_code'] and (not grains.get('offline_mode') or '_node' not in grains.get('role')) %}
{% set reg_code = grains['reg_code'] %}
{% set arch = grains['osarch'] %}

# use registercloudguest for BYOS cloud images where available (images later than 20220103)
{% if salt['file.file_exists']('/usr/sbin/registercloudguest') %}

registercloudguest_registration:
  cmd.run:
    - name: |
        /usr/sbin/registercloudguest --clean
        /usr/sbin/registercloudguest --force-new -r $reg_code {{ ("-e " ~ grains['reg_email']) if grains['reg_email'] else "" }}
        # a second register prevents "permission denied to repo" errors on some older images
        /usr/sbin/registercloudguest --force-new -r $reg_code {{ ("-e " ~ grains['reg_email']) if grains['reg_email'] else "" }}
    - env:
        - reg_code: {{ reg_code }}
    - retry:
        attempts: 3
        interval: 15

# use SUSEConnect in case registercloudguest is not available, e.g. not public cloud or old images
{% else %}

SUSEConnect_registration:
  cmd.run:
    - name: /usr/bin/SUSEConnect -r $reg_code {{ ("-e " ~ grains['reg_email']) if grains['reg_email'] else "" }}
    - env:
        - reg_code: {{ reg_code }}
    - retry:
        attempts: 3
        interval: 15

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

default_sle_module_public_cloud_registration:
  cmd.run:
    - name: /usr/bin/SUSEConnect -p sle-module-public-cloud/12/{{ arch }} -r $reg_code
    - env:
        - reg_code: {{ reg_code }}
    - retry:
        attempts: 3
        interval: 15

{% elif grains['osmajorrelease'] == 15 and grains['provider'] in ['gcp', 'aws', 'azure', 'openstack'] %}
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

# on-demand/PAYG image specific
# PAYG images will use registercloudguest as part of their boot process (regardless of this state)
{% else %}

# Workaround for the 'Script died unexpectedly' error bsc#1158664
# If it is a PAYG image, it will force a new registration before refreshing.
# Also the pure refresh will not be executed as salt will still report failure.
# See: https://github.com/saltstack/salt/issues/16291
workaround_payg_cleanup:
  cmd.run:
    - name: /usr/sbin/registercloudguest --clean
    - onlyif: 'test -e /usr/sbin/registercloudguest'

workaround_payg_new_register:
  cmd.run:
    - name: /usr/sbin/registercloudguest --force-new
    - retry:
        attempts: 3
        interval: 15
    - onlyif: 'test -e /usr/sbin/registercloudguest'
    - require:
      - workaround_payg_cleanup

{% endif %}

{% endif %}
