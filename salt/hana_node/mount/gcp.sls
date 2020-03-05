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
    - extents: 60%FREE

hana_lvm_lvcreate_log:
  lvm.lv_present:
    - name: lv_log
    - vgname: vg_hana
    - extents: 10%FREE

hana_lvm_lvcreate_sap:
  lvm.lv_present:
    - name: lv_sap
    - vgname: vg_hana
    - extents: 5%FREE

hana_lvm_lvcreate_shared:
  lvm.lv_present:
    - name: lv_shared
    - vgname: vg_hana
    - extents: 25%FREE

hana_lvm_lvcreate_backup:
  lvm.lv_present:
    - name: lv_backup
    - vgname: vg_hanabackup
    - extents: 100%FREE

# Format lv
hana_format_lv:
  cmd.run:
    - name: |
        /sbin/mkfs -t {{ grains['hana_fstype'] }} /dev/vg_hana/lv_data && \
        /sbin/mkfs -t {{ grains['hana_fstype'] }} /dev/vg_hana/lv_log && \
        /sbin/mkfs -t {{ grains['hana_fstype'] }} /dev/vg_hana/lv_sap && \
        /sbin/mkfs -t {{ grains['hana_fstype'] }} /dev/vg_hana/lv_shared && \
        /sbin/mkfs -t {{ grains['hana_fstype'] }} /dev/vg_hanabackup/lv_backup

# Mount lv
hana_data_directory_mount:
  file.directory:
    - name: /hana/data
    - user: root
    - mode: "0755"
    - makedirs: True
  mount.mounted:
    - name: /hana/data
    - device: /dev/vg_hana/lv_data
    - fstype: {{ grains['hana_fstype'] }}
    - mkmnt: True
    - persist: True
    - opts: defaults,nofail
    - pass_num: 2
    - require:
      - cmd: hana_format_lv

hana_log_directory_mount:
  file.directory:
    - name: /hana/log
    - user: root
    - mode: "0755"
    - makedirs: True
  mount.mounted:
    - name: /hana/log
    - device: /dev/vg_hana/lv_log
    - fstype: {{ grains['hana_fstype'] }}
    - mkmnt: True
    - persist: True
    - opts: defaults,nofail
    - pass_num: 2
    - require:
      - cmd: hana_format_lv

hana_sap_directory_mount:
  file.directory:
    - name: /usr/sap
    - user: root
    - mode: "0755"
    - makedirs: True
  mount.mounted:
    - name: /usr/sap
    - device: /dev/vg_hana/lv_sap
    - fstype: {{ grains['hana_fstype'] }}
    - mkmnt: True
    - persist: True
    - opts: defaults,nofail
    - pass_num: 2
    - require:
      - cmd: hana_format_lv

hana_shared_directory_mount:
  file.directory:
    - name: /hana/shared
    - user: root
    - mode: "0755"
    - makedirs: True
  mount.mounted:
    - name: /hana/shared
    - device: /dev/vg_hana/lv_shared
    - fstype: {{ grains['hana_fstype'] }}
    - mkmnt: True
    - persist: True
    - opts: defaults,nofail
    - pass_num: 2
    - require:
      - cmd: hana_format_lv

hana_backup_directory_mount:
  file.directory:
    - name: /hana/backup
    - user: root
    - mode: "0755"
    - makedirs: True
  mount.mounted:
    - name: /hana/backup
    - device: /dev/vg_hanabackup/lv_backup
    - fstype: {{ grains['hana_fstype'] }}
    - mkmnt: True
    - persist: True
    - opts: defaults,nofail
    - pass_num: 2
    - require:
      - cmd: hana_format_lv
