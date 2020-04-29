# This state reproduces the chapter 11 of
# https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/sap/high-availability-guide-suse-nfs
# Maybe it should go in the netweaver salt formula directly

install_nfs_client:
  pkg.installed:
    - name: nfs-client
    - retry:
       attempts: 3
       interval: 15

# We cannot use showmount in aws as efs doesn't provide this service
# But we can use it to have more reliable output in the other providers as by use drbd
# efs name is something like: fs-xxxxxxxx.efs.eu-central-1.amazonaws.com 
{% set nfs_server_data = grains['netweaver_nfs_share'].split(':') %}
{% set nfs_server_ip = nfs_server_data[0] %}
{% if 'efs' in grains['netweaver_nfs_share'] %}
wait_until_nfs_is_ready:
  cmd.run:
    - name: until nc -zvw5 {{ nfs_server_ip }} 2049;do sleep 30;done
    - timeout: 600

{% else %}
{% set nfs_export = "''" if nfs_server_data|length == 1 else nfs_server_data[1] %}
wait_until_nfs_is_ready:
  cmd.run:
    - name: until showmount -e {{ nfs_server_ip }} | grep {{ nfs_export }};do sleep 30;done
    - timeout: 600
{% endif %}

# Initialized NFS share folders, only with the first node
# Executing these states in all the nodes might cause errors during deletion, as they try to delete the same files
{% if grains['host_ip'] == grains['host_ips'][0] %}
mount_sapmnt_temporary:
  mount.mounted:
    - name: /tmp/sapmnt
    - device: "{{ grains['netweaver_nfs_share'] }}"
    - fstype: nfs
    - mkmnt: True
    - persist: False
    - opts:
      - defaults
    - require:
      - wait_until_nfs_is_ready

/tmp/sapmnt/sapmnt:
  file.directory:
    - user: root
    - mode: '0755'
    - makedirs: True
    - clean: True
    - require:
      - mount_sapmnt_temporary

/tmp/sapmnt/usrsapsys:
  file.directory:
    - user: root
    - mode: '0755'
    - makedirs: True
    - clean: True
    - require:
      - mount_sapmnt_temporary

# This next folders are created to use as shared folder in Azure
/tmp/sapmnt/ASCS:
  file.directory:
    - user: root
    - mode: '0755'
    - makedirs: True
    - clean: True
    - require:
      - mount_sapmnt_temporary

/tmp/sapmnt/ERS:
  file.directory:
    - user: root
    - mode: '0755'
    - makedirs: True
    - clean: True
    - require:
      - mount_sapmnt_temporary

/tmp/sapmnt/sapcd:
  file.directory:
    - user: root
    - mode: '0755'
    - makedirs: True
    - clean: True
    - require:
      - mount_sapmnt_temporary

unmount_sapmnt:
  mount.unmounted:
    - name: /tmp/sapmnt
    - device: "{{ grains['netweaver_nfs_share'] }}"
    - require:
      - mount_sapmnt_temporary

remove_tmp_folder:
  file.absent:
    - name: /tmp/sapmnt
{% endif %}
