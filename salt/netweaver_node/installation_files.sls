{% set sapcd = '/sapmedia/NW' %}

{% if grains['provider'] == 'libvirt' %}
mount_swpm:
  mount.mounted:
    - name: {{ sapcd }}
    - device: {{ grains['netweaver_inst_media'] }}
    - fstype: nfs
    - mkmnt: True
    - persist: True
    - opts:
      - defaults

{% elif grains['provider'] == 'azure' %}
mount_swpm:
  mount.mounted:
    - name: {{ sapcd }}
    - device: {{ grains['storage_account_path'] }}
    - fstype: cifs
    - mkmnt: True
    - persist: True
    - opts:
      - vers=3.0,username={{ grains['storage_account_name'] }},password={{ grains['storage_account_key'] }},dir_mode=0777,file_mode=0777,sec=ntlmssp

{% elif grains['provider'] == 'aws' %}

# In AWS the NW installation software goes in the NFS share
mount_sapcd:
  mount.mounted:
    - name: {{ sapcd }}
    - device: {{ grains['netweaver_nfs_share'] }}/sapcd
    - fstype: nfs4
    - mkmnt: True
    - persist: True
    - opts:
      - rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2
    - retry:
       attempts: 5
       interval: 60

# Download only if it's the first node
{% if grains['host_ip'] == grains['host_ips'][0] %}
download_nw_files_from_s3:
  cmd.run:
    - name: "aws s3 sync {{ grains['s3_bucket'] }} {{ sapcd }} --region {{ grains['region'] }} --only-show-errors"
    - onlyif: "aws s3 sync --dryrun {{ grains['s3_bucket'] }} {{ sapcd }} --region {{ grains['region'] }} | grep download > /dev/null 2>&1"
    - output_loglevel: quiet
    - hide_output: True
{% endif %}

wait_until_sw_downloaded:
    cmd.run:
      - name: |
          until ! aws s3 sync --dryrun {{ grains['s3_bucket'] }} {{ sapcd }} \
          --region {{ grains['region'] }} | grep download > /dev/null 2>&1;do sleep 30;done
      - output_loglevel: quiet
      - hide_output: True
      - timeout: 600

sapcd_folder:
  file.directory:
    - name: {{ sapcd }}
    - user: root
    - group: root
    - dir_mode: "0755"
    - file_mode: "0755"
    - recurse:
      - user
      - group
      - mode
    - require:
      - wait_until_sw_downloaded

{% elif grains['provider'] == 'gcp' %}
{% set nw_inst_disk_device = salt['cmd.run']('realpath '~grains['nw_inst_disk_device']) %}
nw_inst_partition:
  cmd.run:
    - name: |
        /usr/sbin/parted -s {{ nw_inst_disk_device }} mklabel msdos && \
        /usr/sbin/parted -s {{ nw_inst_disk_device }} mkpart primary ext2 1M 100% && sleep 1 && \
        /sbin/mkfs -t xfs {{ nw_inst_disk_device }}1
    - unless: ls {{ nw_inst_disk_device }}1

mount_swpm:
  mount.mounted:
    - name: {{ sapcd }}
    - device: {{ nw_inst_disk_device }}1
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
    - name: rclone copy remote:{{ grains['netweaver_software_bucket'] }} {{ sapcd }}

swpm_folder:
  file.directory:
    - name: {{ sapcd }}
    - user: root
    - group: root
    - dir_mode: "0755"
    - file_mode: "0755"
    - recurse:
      - user
      - group
      - mode

{% endif %}
