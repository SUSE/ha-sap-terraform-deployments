# Create Physical volumes
hana_lvm_pvcreate_data:
  lvm.pv_present:
    - name: {{ grains['hana_disk_device'] }}

hana_lvm_pvcreate_backup:
  lvm.pv_present:
    - name: {{ grains['hana_backup_device'] }}

# Create Volume groups
hana_lvm_vgcreate_data:
  lvm.vg_present:
    - name: vg_hana
    - devices: {{ grains['hana_disk_device'] }}

hana_lvm_vgcreate_backup:
  lvm.vg_present:
    - name: vg_hanabackup
    - devices: {{ grains['hana_backup_device'] }}

# Create Logical volumes
hana_lvm_lvcreate_data:
  lvm.lv_present:
    - name: lv_data
    - vgname: vg_hana
    - extents: 60%VG

hana_lvm_lvcreate_log:
  lvm.lv_present:
    - name: lv_log
    - vgname: vg_hana
    - extents: 10%VG

hana_lvm_lvcreate_sap:
  lvm.lv_present:
    - name: lv_sap
    - vgname: vg_hana
    - extents: 5%VG

hana_lvm_lvcreate_shared:
  lvm.lv_present:
    - name: lv_shared
    - vgname: vg_hana
    - extents: 25%VG

hana_lvm_lvcreate_backup:
  lvm.lv_present:
    - name: lv_backup
    - vgname: vg_hanabackup
    - extents: 100%FREE

{% for vg in ['hana', 'hanabackup'] %}

{% if vg == 'hana' %}
  {% set lvs = ['data', 'log', 'sap', 'shared'] %}
{% elif vg == 'hanabackup' %}
  {% set lvs = ['backup'] %}
{% endif %}

{% for lv in lvs %}
{% if lv == 'sap' %}
  {% set basedir = '/usr' %}
{% else %}
  {% set basedir = '/hana' %}
{% endif %}

# Format lvs
hana_format_lv_vg_{{ vg }}_lv_{{ lv }}:
  cmd.run:
    - name: |
        /sbin/mkfs -t {{ grains['hana_fstype'] }} /dev/vg_{{ vg }}/lv_{{ lv }}
    - unless: blkid /dev/mapper/vg_{{ vg }}-lv_{{ lv }}

# Mount lvs
hana_{{ lv }}_directory_mount:
  file.directory:
    - name: {{ basedir }}/{{ lv }}
    - user: root
    - mode: "0755"
    - makedirs: True
  mount.mounted:
    - name: {{ basedir }}/{{ lv }}
    - device: /dev/vg_{{ vg }}/lv_{{ lv }}
    - fstype: {{ grains['hana_fstype'] }}
    - mkmnt: True
    - persist: True
    - opts: defaults,nofail
    - pass_num: 2
    - require:
      - cmd: hana_format_lv_vg_{{ vg }}_lv_{{ lv }}

{% endfor %}
{% endfor %}
