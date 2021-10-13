# This state reproduces the chapter 11 of
# https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/sap/high-availability-guide-suse-nfs
# Maybe it should go in the netweaver salt formula directly

{% if grains['netweaver_nfs_share'] or grains['netweaver_shared_storage_type'] == "anf" %}

include:
  - shared_storage.nfs

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
      - sls: shared_storage.nfs

/tmp/sapmnt/usrsapsys:
  file.directory:
    - user: root
    - mode: '0755'
    - makedirs: True
    - clean: True
    - require:
      - sls: shared_storage.nfs

# This next folders are created to use as shared folder in Azure
/tmp/sapmnt/ASCS:
  file.directory:
    - user: root
    - mode: '0755'
    - makedirs: True
    - clean: True
    - require:
      - sls: shared_storage.nfs

/tmp/sapmnt/ERS:
  file.directory:
    - user: root
    - mode: '0755'
    - makedirs: True
    - clean: True
    - require:
      - sls: shared_storage.nfs

/tmp/sapmnt/sapcd:
  file.directory:
    - user: root
    - mode: '0755'
    - makedirs: True
    - clean: True
    - require:
      - sls: shared_storage.nfs

# Check if the previously created folder exist and delay the unmount
# https://github.com/SUSE/ha-sap-terraform-deployments/issues/633
check_sapmnt_folder_exists:
  file.exists:
    - name: /tmp/sapmnt/sapmnt
    - require:
      - sls: shared_storage.nfs

wait_before_unmount_sapmnt:
  module.run:
    - test.sleep:
      - length: 3
    - require:
      - check_sapmnt_folder_exists

unmount_sapmnt:
  mount.unmounted:
    - name: /tmp/sapmnt
    - require:
      - sls: shared_storage.nfs
      - wait_before_unmount_sapmnt

wait_before_remove_tmp_folder:
  module.run:
    - test.sleep:
      - length: 3
    - require:
      - file: /tmp/sapmnt/sapmnt
      - unmount_sapmnt

remove_tmp_folder:
  file.absent:
    - name: /tmp/sapmnt
    - require:
      - wait_before_remove_tmp_folder

{% endif %}
{% endif %}
