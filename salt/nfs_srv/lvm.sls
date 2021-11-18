# exclude DVD drive and root disk
{% set pvs = grains['disks']|reject('match', 'sr0')|reject('match', 'sda')|list %}
{% set fstype = 'xfs' %}
{% set basedir = grains['nfs_mounting_point'] %}

# Create Physical volumes
{% for pv in pvs %}
nfs_lvm_pvcreate_{{ pv }}:
  lvm.pv_present:
    - name: /dev/{{ pv }}
{% endfor %}

# Create Volume group
nfs_lvm_vgcreate_data:
  lvm.vg_present:
    - name: vg_nfs
    - devices:
    {% for pv in pvs %}
      - /dev/{{ pv }}
    {% endfor %}

# Activate Volume group (may be needed after re-provisioning)
nfs_lvm_vgactivate_data:
  cmd.run:
    - name: vgchange -ay vg_nfs
    - require:
      - lvm: nfs_lvm_vgcreate_data

# Create Logical volume
nfs_lvm_lvcreate_sapdata:
  lvm.lv_present:
    - name: lv_sapdata
    - vgname: vg_nfs
    - extents: 100%VG

{% for vg in ['nfs'] %}

{% if vg == 'nfs' %}
  {% set lvs = ['sapdata'] %}
{% endif %}

{% for lv in lvs %}

# Format lvs
nfs_format_lv_vg_{{ vg }}_lv_{{ lv }}:
  cmd.run:
    - name: |
        /sbin/mkfs -t {{ fstype }} /dev/vg_{{ vg }}/lv_{{ lv }}
    - unless: blkid /dev/mapper/vg_{{ vg }}-lv_{{ lv }}

{% endfor %}
{% endfor %}

# Mount sapdata
nfs_sapdata_directory_mount:
  file.directory:
    - name: {{ basedir }}
    - user: root
    - mode: "0755"
    - makedirs: True
  mount.mounted:
    - name: {{ basedir }}
    - device: /dev/vg_nfs/lv_sapdata
    - fstype: {{ fstype }}
    - mkmnt: True
    - persist: True
    - opts: defaults,nofail
    - pass_num: 2
    - require:
      - cmd: nfs_format_lv_vg_nfs_lv_sapdata

