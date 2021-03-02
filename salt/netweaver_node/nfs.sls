# This state reproduces the chapter 11 of
# https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/sap/high-availability-guide-suse-nfs
# Maybe it should go in the netweaver salt formula directly

install_nfs_client:
  pkg.installed:
    - name: nfs-client
    - retry:
       attempts: 3
       interval: 15

# We cannot use showmount as some of the required ports are not always available
# (aws efs storage or azure load balancers don't serve portmapper 111 and mountd 20048 ports)
netcat-openbsd:
 pkg.installed:
   - retry:
      attempts: 3
      interval: 15

{% if grains['netweaver_nfs_share'] %}
{% set nfs_server_ip = grains['netweaver_nfs_share'].split(':')[0] %}
wait_until_nfs_is_ready:
  cmd.run:
    - name: until nc -zvw5 {{ nfs_server_ip }} 2049;do sleep 30;done
    - output_loglevel: quiet
    - timeout: 1200
    - require:
      - pkg: netcat-openbsd

# Initialized NFS share folders, only with the first node
# Executing these states in all the nodes might cause errors during deletion, as they try to delete the same files
{% if grains['host_ip'] == grains['host_ips'][0] %}
# Add a delay to the folder creation https://github.com/SUSE/ha-sap-terraform-deployments/issues/633
wait_before_mount_sapmnt_temporary:
  module.run:
    - test.sleep:
      - length: 3
    - require:
      - wait_until_nfs_is_ready

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
      - wait_before_mount_sapmnt_temporary

# Add a delay to the folder creation https://github.com/SUSE/ha-sap-terraform-deployments/issues/633
wait_after_mount_sapmnt_temporary:
  module.run:
    - test.sleep:
      - length: 3
    - require:
      - mount_sapmnt_temporary

/tmp/sapmnt/sapmnt:
  file.directory:
    - user: root
    - mode: '0755'
    - makedirs: True
    - clean: True
    - require:
      - mount_sapmnt_temporary
      - wait_after_mount_sapmnt_temporary

/tmp/sapmnt/usrsapsys:
  file.directory:
    - user: root
    - mode: '0755'
    - makedirs: True
    - clean: True
    - require:
      - mount_sapmnt_temporary
      - wait_after_mount_sapmnt_temporary

# This next folders are created to use as shared folder in Azure
/tmp/sapmnt/ASCS:
  file.directory:
    - user: root
    - mode: '0755'
    - makedirs: True
    - clean: True
    - require:
      - mount_sapmnt_temporary
      - wait_after_mount_sapmnt_temporary

/tmp/sapmnt/ERS:
  file.directory:
    - user: root
    - mode: '0755'
    - makedirs: True
    - clean: True
    - require:
      - mount_sapmnt_temporary
      - wait_after_mount_sapmnt_temporary

/tmp/sapmnt/sapcd:
  file.directory:
    - user: root
    - mode: '0755'
    - makedirs: True
    - clean: True
    - require:
      - mount_sapmnt_temporary
      - wait_after_mount_sapmnt_temporary

# Check if the previously created folder exist and delay the unmount
# https://github.com/SUSE/ha-sap-terraform-deployments/issues/633
check_sapmnt_folder_exists:
  file.exists:
    - name: /tmp/sapmnt/sapmnt
    - require:
      - mount_sapmnt_temporary
      - wait_after_mount_sapmnt_temporary

wait_before_unmount_sapmnt:
  module.run:
    - test.sleep:
      - length: 3
    - require:
      - check_sapmnt_folder_exists

unmount_sapmnt:
  mount.unmounted:
    - name: /tmp/sapmnt
    - device: "{{ grains['netweaver_nfs_share'] }}"
    - require:
      - mount_sapmnt_temporary
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
