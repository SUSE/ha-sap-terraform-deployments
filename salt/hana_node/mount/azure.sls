# Configure physical volumes
{%- for disks in grains['hana_data_disks_configuration']['disks_size'].split(',') %}
hana_lvm_pvcreate_lun{{ loop.index0 }}_azure:
  lvm.pv_present:
    - name: /dev/disk/azure/scsi1/lun{{ loop.index0 }}
{%- endfor %}

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
{%- set lun_count = luns|length %}
{%- for lv_size in grains['hana_data_disks_configuration']['lv_sizes'].split('#')[vg_index].split(',') %}
hana_lvm_lvcreate_{{ vg }}_{{ loop.index0 }}_azure:
  lvm.lv_present:
    - name: lv_hana_{{ vg }}_{{ loop.index0 }}
    - vgname: vg_hana_{{ vg }}
    - extents: {{ lv_size }}%FREE
    - stripes: {{ lun_count }}

hana_format_lv_{{ vg }}_{{ loop.index0 }}_azure:
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
            path: {{ grains['hana_data_disks_configuration']['paths'].split('#')[vg_index].split(',')[loop.index0] }}
            fstype: {{ grains['hana_fstype'] }}
    - require:
      - hana_format_lv_{{ vg }}_{{ loop.index0 }}_azure

{%- endfor %}
{%- endfor %}

{%- if grains['hana_scale_out_enabled'] and grains['hana_scale_out_shared_storage_type'] == "anf" %}
## scale-out on ANF NFS storage

install_nfs_client:
  pkg.installed:
    - name: nfs-client
    - retry:
       attempts: 3
       interval: 15

/etc/idmapd.conf:
  file.line:
    - match: "^Domain = localdomain"
    - mode: replace
    - content: |
        Domain = defaultv4iddomain.com
    - require:
      - pkg: nfs-client

nfs-idmapd:
  service.running:
    - enable: True
    - require:
      - pkg: nfs-client
      - file: /etc/idmapd.conf
    - watch:
      - pkg: nfs-client
      - file: /etc/idmapd.conf

clear_idmap_cache:
  cmd.run:
    - name: nfsidmap -c
    - onchanges:
      - file: /etc/idmapd.conf

# We cannot use showmount as some of the required ports are not always available
# (aws efs storage or azure load balancers don't serve portmapper 111 and mountd 20048 ports)
netcat-openbsd:
 pkg.installed:
   - retry:
      attempts: 3
      interval: 15

# define sites based on even/odd hostname
{%- set host_num = grains['host']|replace(grains['name_prefix'], '') %}
{%- if (host_num|int % 2) == 1 %}
{%- set site = 1 %}
{%- elif (host_num|int % 2) == 0 %}
{%- set site = 2 %}
{%- endif %}

{%- for mount in ["data", "log", "backup", "shared"] %}

wait_until_nfs_is_ready_{{ mount }}:
  cmd.run:
    - name: until nc -zvw5 {{ grains['anf_mount_ip'][mount][site - 1] }} 2049;do sleep 30;done
    - output_loglevel: quiet
    - timeout: 1200
    - require:
      - pkg: netcat-openbsd

mount_hana_{{ mount }}:
  file.directory:
    - name: /hana/{{ mount }}
    - user: root
    - mode: "0755"
    - makedirs: True
  mount.mounted:
    - name: /hana/{{ mount }}
    - device: {{ grains['anf_mount_ip'][mount][ site - 1] }}:/hana-{{ mount }}-{{ site }}
    - fstype: nfs
    - mkmnt: True
    - persist: True
    - opts: rw,hard,rsize=1048576,wsize=1048576,sec=sys,vers=4.1,tcp,_netdev
    - require:
      - wait_until_nfs_is_ready_{{ mount }}

permissions_hana_{{ mount }}:
  file.directory:
    - name: /hana/{{ mount }}
    - user: root
    - mode: "0755"
    - makedirs: True
    - require:
      - mount_hana_{{ mount }}

{%- endfor %}
{%- endif %}
