{%- set devices = [] %}
{%- set tf_devices = grains['hana_data_disks_configuration']['devices'].split(',')|default([]) %}
{%- for tf_device in tf_devices %}
  {% if grains['provider'] == 'aws' %}
    {%- set devices = devices.append(tf_device | regex_replace('^vol-', '/dev/disk/by-id/nvme-Amazon_Elastic_Block_Store_vol')) %}
  {% elif grains['provider'] == 'azure' %}
    {%- set devices = devices.append(tf_device | regex_replace('^', '/dev/disk/azure/scsi1/lun')) %}
  {% elif grains['provider'] == 'gcp' %}
    {%- set devices = devices.append(tf_device | regex_replace('^', '/dev/disk/by-id/google-')) %}
  {% elif grains['provider'] == 'openstack' %}
    # first element is root disk
    {% if loop.index0 != 0 %}
      {%- set devices = devices.append(tf_device | regex_replace('^', '/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_')) %}
    {% endif %}
  {% else %}
    {%- set devices = devices.append(tf_device) %}
  {% endif %}
{% endfor %}

lvm2_package:
  pkg.installed:
    - name: lvm2
    - retry:
        attempts: 3
        interval: 15

{%- for vg in grains['hana_data_disks_configuration']['names'].split('#') %}

{%- set vg_index = loop.index0 %}
{%- set vg_lun_indices = grains['hana_data_disks_configuration']['luns'].split('#')[vg_index].split(',') %}
{%- set vg_devices = [] %}

{%- for index in vg_lun_indices %}
# Configure physical volumes
{%- set vg_lun_index = index|int %}
{%- set vg_device = devices[vg_lun_index] %}
{%- set vg_devices = vg_devices.append(vg_device) %}
hana_lvm_pvcreate_{{ vg_lun_index }}_{{ vg_device }}:
  lvm.pv_present:
    - name: {{ vg_device }}
{%- endfor %}

# Configure volume groups
hana_lvm_vgcreate_{{ vg }}:
  lvm.vg_present:
    - name: vg_hana_{{ vg }}
    - devices:
      {%- for vg_device in vg_devices %}
      - {{ vg_device }}
      {%- endfor %}

# Configure the logical volumes
{%- set vg_device_count = vg_devices|length %}
{%- for lv_size in grains['hana_data_disks_configuration']['lv_sizes'].split('#')[vg_index].split(',') %}
hana_lvm_lvcreate_{{ vg }}_{{ loop.index0 }}:
  lvm.lv_present:
    - name: lv_hana_{{ vg }}_{{ loop.index0 }}
    - vgname: vg_hana_{{ vg }}
    - extents: {{ lv_size }}%FREE
    - stripes: {{ vg_device_count }}

hana_format_lv_{{ vg }}_{{ loop.index0 }}:
  cmd.run:
    - name: /sbin/mkfs -t {{ grains['hana_fstype'] }} /dev/vg_hana_{{ vg }}/lv_hana_{{ vg }}_{{ loop.index0 }}
    - unless: blkid /dev/mapper/vg_hana_{{ vg }}-lv_hana_{{ vg }}_{{ loop.index0 }}

# This state mounts the new disk using the UUID, as we need to get this value running blkid after the
# previous command, we need to run it as a new state execution
mount_{{ vg }}_{{ loop.index0 }}:
  module.run:
    - state.sls:
      - mods:
        - hana_node.mount.mount_uuid
      - pillar:
          data:
            device: /dev/mapper/vg_hana_{{ vg }}-lv_hana_{{ vg }}_{{ loop.index0 }}
            path: {{ grains['hana_data_disks_configuration']['paths'].split('#')[vg_index] }}
            fstype: {{ grains['hana_fstype'] }}
    - require:
      - hana_format_lv_{{ vg }}_{{ loop.index0 }}

{%- endfor %}
{%- endfor %}
