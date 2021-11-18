{% set basedir = grains['nfs_mounting_point'] %}

# create directories for HANA scale-out deployment
{% if grains['hana_scale_out_shared_storage_type'] == 'nfs' %}
{% set hana_sid = grains['hana_sid'].upper() %}
{% set hana_instance = '{:0>2}'.format(grains['hana_instance']) %}
{% set mounts = ["data", "log", "backup", "shared"] %}
{%- for site in [1,2] %}
{%- for mount in mounts %}
dir_{{ hana_sid }}_{{ hana_instance }}_site_{{ site }}_{{ mount }}:
  file.directory:
    - name: {{ basedir }}/{{ hana_sid }}/{{ hana_instance }}/site_{{ site }}/{{ mount }}
    - makedirs: True
{% endfor %}
{% endfor %}
{% endif %}

# create directories for Netweaver deployment
{% if grains['netweaver_shared_storage_type'] == 'nfs' %}
{% set netweaver_sid = grains['netweaver_sid'].upper() %}
{% set netweaver_ascs_instance = '{:0>2}'.format(grains['netweaver_ascs_instance']) %}
{% set netweaver_ers_instance = '{:0>2}'.format(grains['netweaver_ers_instance']) %}
{% set netweaver_ascs_dir = 'ASCS' + netweaver_ascs_instance %}
{% set netweaver_ers_dir = 'ERS' + netweaver_ers_instance %}
{% set mounts = ["sapmnt", "usrsapsys", netweaver_ascs_dir, netweaver_ers_dir] %}
{%- for mount in mounts %}
dir_{{ netweaver_sid }}_{{ mount }}:
  file.directory:
    - name: {{ basedir }}/{{ netweaver_sid }}/{{ mount }}
    - makedirs: True
{% endfor %}
{% endif %}
