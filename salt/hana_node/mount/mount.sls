hana_partition:
  cmd.run:
    - name: |
        /usr/sbin/parted -s {{ grains['hana_disk_device'] }} mklabel msdos && \
        /usr/sbin/parted -s {{ grains['hana_disk_device'] }} mkpart primary ext2 1M 100% && sleep 1 && \
        /sbin/mkfs -t {{ grains['hana_fstype'] }} {{ grains['hana_disk_device'] }}1
    - unless: ls {{ grains['hana_disk_device'] }}1
    - require:
      - pkg: parted

hana_directory:
  file.directory:
    - name: /hana
    - user: root
    - mode: "0755"
    - makedirs: True
  mount.mounted:
    - name: /hana
    - device: {{ grains['hana_disk_device'] }}1
    - fstype: {{ grains['hana_fstype'] }}
    - mkmnt: True
    - persist: True
    - opts:
      - defaults
    - require:
      - cmd: hana_partition

# New content
hana_install_nfs_client:
  pkg.installed:
    - name: nfs-client
    - retry:
       attempts: 3
       interval: 15

# We cannot use showmount as some of the required ports are not always available
# (aws efs storage or azure load balancers don't serve portmapper 111 and mountd 20048 ports)
hana_netcat_openbsd:
 pkg.installed:
   - name: netcat-openbsd
   - retry:
      attempts: 3
      interval: 15

{% if grains['hostname'][-1]|int % 2 != 0 %}
{% set nfs_server_ip = '192.168.137.22' %}
{% else %}
{% set nfs_server_ip = '192.168.137.25' %}
{% endif %}
hana_wait_until_nfs_is_ready:
  cmd.run:
    - name: until nc -zvw5 {{ nfs_server_ip }} 2049;do sleep 30;done
    - timeout: 3000
    - require:
      - pkg: netcat-openbsd

{% if grains['host_ip'] == grains['host_ips'][0] or grains['host_ip'] == grains['host_ips'][1] %}
mount_HA1_temporary:
  mount.mounted:
    - name: /tmp/PRD
    - device: "{{ nfs_server_ip }}:/HA1"
    - fstype: nfs
    - mkmnt: True
    - persist: False
    - opts:
      - defaults
    - require:
      - hana_wait_until_nfs_is_ready

wait_a_bit_a:
  cmd.run:
    - name: sleep 5

/tmp/PRD/shared:
  file.directory:
    - user: root
    - mode: '0755'
    - makedirs: True
    - clean: True
    - require:
      - mount_HA1_temporary

/tmp/PRD/data:
  file.directory:
    - user: root
    - mode: '0755'
    - makedirs: True
    - clean: True
    - require:
      - mount_HA1_temporary

/tmp/PRD/log:
  file.directory:
    - user: root
    - mode: '0755'
    - makedirs: True
    - clean: True
    - require:
      - mount_HA1_temporary

wait_a_bit_b:
  cmd.run:
    - name: sleep 5

unmount_sapmnt:
  mount.unmounted:
    - name: /tmp/PRD
    - device: "{{ nfs_server_ip }}:/HA1"
    - require:
      - mount_HA1_temporary

wait_a_bit_c:
  cmd.run:
    - name: sleep 5

remove_tmp_folder:
  file.absent:
    - name: /tmp/PRD

{% endif %}

wait_a_bit_more:
  cmd.run:
    - name: sleep 45

mount_hana_shared:
  mount.mounted:
    - name: /hana/shared/PRD
    - device: "{{ nfs_server_ip }}:/HA1/shared"
    - fstype: nfs4
    - mkmnt: True
    - persist: True
    - opts:
      - defaults
    - require:
      - hana_wait_until_nfs_is_ready

mount_hana_data:
  mount.mounted:
    - name: /hana/data/PRD
    - device: "{{ nfs_server_ip }}:/HA1/data"
    - fstype: nfs4
    - mkmnt: True
    - persist: True
    - opts:
      - defaults
    - require:
      - hana_wait_until_nfs_is_ready

mount_hana_log:
  mount.mounted:
    - name: /hana/log/PRD
    - device: "{{ nfs_server_ip }}:/HA1/log"
    - fstype: nfs4
    - mkmnt: True
    - persist: True
    - opts:
      - defaults
    - require:
      - hana_wait_until_nfs_is_ready