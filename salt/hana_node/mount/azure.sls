# Configure physical volumes
{%- for disks in grains['hana_data_disks_configuration']['disks_size'].split(',') %}
hana_lvm_pvcreate_lun{{ loop.index0 }}_azure:
  lvm.pv_present:
    - name: /dev/disk/azure/scsi1/lun{{ loop.index0 }}
{% endfor %}

# Configure volume groups
{%- for vg in grains['hana_data_disks_configuration']['names'].split('#') %}
{%- set vg_index = loop.index0 %}
{%- set luns = grains['hana_data_disks_configuration']['luns'].split('#')[vg_index].split(',') %}
hana_lvm_vgcreate_{{ vg }}_azure:
  lvm.vg_present:
    - name: vg_hana_{{ vg }}
    - devices:
      {%- for lun_index in luns %}
      - /dev/disk/azure/scsi1/lun{{ lun_index }}
      {%- endfor %}

# Configure the logical volumes
{%- for lv_size in grains['hana_data_disks_configuration']['lv_sizes'].split('#')[vg_index].split(',') %}
hana_lvm_lvcreate_{{ vg }}_{{ loop.index0 }}_azure:
  lvm.lv_present:
    - name: lv_hana_{{ vg }}_{{ loop.index0 }}
    - vgname: vg_hana_{{ vg }}
    - extents: {{ lv_size }}%FREE
    - stripes: {{ loop.length }}

hana_format_lv_{{ vg }}_{{ loop.index0 }}_azure:
  cmd.run:
    - name: /sbin/mkfs -t {{ grains['hana_fstype'] }} /dev/vg_hana_{{ vg }}/lv_hana_{{ vg }}_{{ loop.index0 }}

hana_{{ vg }}_{{ loop.index0 }}_directory_mount_azure:
  file.directory:
    - name: {{ grains['hana_data_disks_configuration']['paths'].split('#')[vg_index].split(',')[loop.index0] }}
    - user: root
    - mode: "0755"
    - makedirs: True
  mount.mounted:
    - name: {{ grains['hana_data_disks_configuration']['paths'].split('#')[vg_index].split(',')[loop.index0] }}
    - device: /dev/vg_hana_{{ vg }}/lv_hana_{{ vg }}_{{ loop.index0 }}
    - fstype: {{ grains['hana_fstype'] }}
    - mkmnt: True
    - persist: True
    - opts: defaults,nofail
    - pass_num: 2

{% endfor %}
{%- endfor %}
