install_nfs_client:
  pkg.installed:
    - name: nfs-client
    - retry:
       attempts: 3
       interval: 15

wait_for_nfs_machine:
  cmd.run:
    - name: until ping -w 5 {{ grains['netweaver_nfs_share'].split(':')[0] }};do sleep 10;done
    - output_loglevel: quiet
    - hide_output: True
    - timeout: 2400
    - require:
      - install_nfs_client

wait_for_nfs_share:
  cmd.run:
    - name: until showmount -e {{ grains['netweaver_nfs_share'].split(':')[0] }};do sleep 10;done
    - output_loglevel: quiet
    - hide_output: True
    - timeout: 2400
    - require:
      - wait_for_nfs_machine

# Initialized NFS share folders, only with the first node
# Executing these states in all the nodes might cause errors during deletion, as they try to delete the same files
{% if grains['host_ip'] == grains['host_ips'][0] %}
mount_sapmnt:
  mount.mounted:
    - name: /tmp/sapmnt
    - device: {{ grains['netweaver_nfs_share'] }}
    - fstype: nfs
    - mkmnt: True
    - persist: True
    - opts:
      - defaults
    - require:
      - wait_for_nfs_share

/tmp/sapmnt/sapmnt:
  file.directory:
    - user: root
    - mode: '0755'
    - makedirs: True
    - clean: True
    - require:
      - wait_for_nfs_share

/tmp/sapmnt/usrsapsys:
  file.directory:
    - user: root
    - mode: '0755'
    - makedirs: True
    - clean: True
    - require:
      - wait_for_nfs_share

unmount_sapmnt:
  mount.unmounted:
    - name: /tmp/sapmnt
    - device: {{ grains['netweaver_nfs_share'] }}
    - require:
      - wait_for_nfs_share
{% endif %}
