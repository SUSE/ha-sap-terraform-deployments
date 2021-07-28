# Configure volume groups
{%- for vg in grains['drbd_data_disks_configuration_netweaver']['names'].split('#') %}
{%- set vg_index = loop.index0 %}
{%- set luns = grains['drbd_data_disks_configuration_netweaver']['luns'].split('#')[vg_index].split(',') %}
netweaver_lvm_vgcreate_{{ vg }}:
  lvm.vg_present:
    - name: vg_netweaver_{{ vg }}
    - devices:
      {%- for lun_index in luns %}
      - /dev/disk/azure/scsi1/lun{{ lun_index }}
      {%- endfor %}

# Configure the logical volumes
{%- set lun_count = luns|length %}
{%- for lv_size in grains['drbd_data_disks_configuration_netweaver']['lv_sizes'].split('#')[vg_index].split(',') %}
netweaver_lvm_lvcreate_{{ vg }}:
  lvm.lv_present:
    - name: lv_netweaver_{{ vg }}
    - vgname: vg_netweaver_{{ vg }}
    - extents: {{ lv_size }}%FREE
    - stripes: {{ lun_count }}

{% endfor %}
{%- endfor %}

## configure hana devices
# Configure volume groups
{%- for vg in grains['drbd_data_disks_configuration_hana']['names'].split('#') %}
{%- set vg_index = loop.index0 %}
{%- set luns = grains['drbd_data_disks_configuration_hana']['luns'].split('#')[vg_index].split(',') %}
hana_lvm_vgcreate_{{ vg }}:
  lvm.vg_present:
    - name: vg_hana_{{ vg }}
    - devices:
      {%- for lun_index in luns %}
      - /dev/disk/azure/scsi1/lun{{ lun_index }}
      {%- endfor %}

# Configure the logical volumes
{%- set lun_count = luns|length %}
{%- for lv_size in grains['drbd_data_disks_configuration_hana']['lv_sizes'].split('#')[vg_index].split(',') %}
hana_lvm_lvcreate_{{ vg }}:
  lvm.lv_present:
    - name: lv_hana_{{ vg }}
    - vgname: vg_hana_{{ vg }}
    - extents: {{ lv_size }}%FREE
    - stripes: {{ lun_count }}

{% endfor %}
{%- endfor %}
