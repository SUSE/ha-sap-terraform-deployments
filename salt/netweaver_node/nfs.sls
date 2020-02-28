# This state reproduces the chapter 11 of
# https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/sap/high-availability-guide-suse-nfs
# Maybe it should go in the netweaver salt formula directly

install_nfs_client:
  pkg.installed:
    - name: nfs-client
    - retry:
       attempts: 3
       interval: 15

mount_sapmnt_temporary:
  mount.mounted:
    - name: /tmp/sapmnt
    - device: "{{ grains['netweaver_nfs_share'] }}"
    - fstype: nfs
    - mkmnt: True
    - persist: False
    - opts:
      - defaults
    - retry:
       attempts: 30
       interval: 60

# Initialized NFS share folders, only with the first node
# Executing these states in all the nodes might cause errors during deletion, as they try to delete the same files
{% if grains['host_ip'] == grains['host_ips'][0] %}
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

{% endif %}

unmount_sapmnt:
  mount.unmounted:
    - name: /tmp/sapmnt
    - device: "{{ grains['netweaver_nfs_share'] }}"
    - require:
      - mount_sapmnt_temporary

remove_tmp_folder:
  file.absent:
    - name: /tmp/sapmnt
