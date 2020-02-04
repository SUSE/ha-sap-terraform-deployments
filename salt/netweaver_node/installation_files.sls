{% if grains['provider'] == 'libvirt' %}
mount_swpm:
  mount.mounted:
    - name: /netweaver_inst_media
    - device: {{ grains['netweaver_inst_media'] }}
    - fstype: nfs
    - mkmnt: True
    - persist: True
    - opts:
      - defaults

{% elif grains['provider'] == 'azure' %}
mount_swpm:
  mount.mounted:
    - name: /netweaver_inst_media
    - device: {{ grains['storage_account_path'] }}
    - fstype: cifs
    - mkmnt: True
    - persist: True
    - opts:
      - vers=3.0,username={{ grains['storage_account_name'] }},password={{ grains['storage_account_key'] }},dir_mode=0777,file_mode=0777,sec=ntlmssp

{% elif grains['provider'] == 'gcp' %}
nw_inst_partition:
  cmd.run:
    - name: |
        /usr/sbin/parted -s {{ grains['nw_inst_disk_device'] }} mklabel msdos && \
        /usr/sbin/parted -s {{ grains['nw_inst_disk_device'] }} mkpart primary ext2 1M 100% && sleep 1 && \
        /sbin/mkfs -t xfs {{ grains['nw_inst_disk_device'] }}1
    - unless: ls {{ grains['nw_inst_disk_device'] }}1

mount_swpm:
  mount.mounted:
    - name: /netweaver_inst_media
    - device: {{ grains['nw_inst_disk_device'] }}1
    - fstype: xfs
    - mkmnt: True
    - persist: True
    - opts:
      - defaults
    - require:
      - cmd: nw_inst_partition

install_rclone:
  cmd.run:
    - name: "curl https://rclone.org/install.sh | sudo bash"

configure_rclone:
  file.append:
    - name: /root/.rclone.conf
    - source: /root/salt/hana_node/files/rclone/gcp.conf

download_files_from_gcp:
  cmd.run:
    - name: rclone copy remote:{{ grains['netweaver_software_bucket'] }} /netweaver_inst_media

swpm_folder:
  file.directory:
    - name: /netweaver_inst_media
    - user: root
    - group: root
    - dir_mode: "0755"
    - file_mode: "0755"
    - recurse:
      - user
      - group
      - mode

{% endif %}
