{% if grains['provider'] == 'libvirt' %}
mount_swpm:
  mount.mounted:
    - name: {{ grains['netweaver_inst_folder'] }}
    - device: {{ grains['netweaver_inst_media'] }}
    - fstype: nfs
    - mkmnt: True
    - persist: True
    - opts:
      - defaults

{% elif grains['provider'] == 'azure' %}
mount_swpm:
  mount.mounted:
    - name: {{ grains['netweaver_inst_folder'] }}
    - device: {{ grains['storage_account_path'] }}
    - fstype: cifs
    - mkmnt: True
    - persist: True
    - opts:
      - vers=3.0,username={{ grains['storage_account_name'] }},password={{ grains['storage_account_key'] }},dir_mode=0777,file_mode=0777,sec=ntlmssp

{% elif grains['provider'] in ['gcp', 'aws'] %}
{% set netweaver_inst_disk_device = salt['cmd.run']('realpath '~grains['netweaver_inst_disk_device']) %}
nw_inst_partition:
  cmd.run:
    - name: |
        /usr/sbin/parted -s {{ netweaver_inst_disk_device }} mklabel msdos && \
        /usr/sbin/parted -s {{ netweaver_inst_disk_device }} mkpart primary ext2 1M 100% && sleep 1 && \
        /sbin/mkfs -t xfs {{ netweaver_inst_disk_device }}1
    - unless: ls {{ netweaver_inst_disk_device }}1

mount_swpm:
  mount.mounted:
    - name: {{ grains['netweaver_inst_folder'] }}
    - device: {{ netweaver_inst_disk_device }}1
    - fstype: xfs
    - mkmnt: True
    - persist: True
    - opts:
      - defaults
    - require:
      - cmd: nw_inst_partition

{% if grains['provider'] == 'gcp' %}

{% from 'macros/download_from_google_storage.sls' import download_from_google_storage with context %}

{{ download_from_google_storage(
  grains['gcp_credentials_file'],
  grains['netweaver_software_bucket'],
  grains['netweaver_inst_folder']) }}

{% elif grains['provider'] == 'aws' %}

download_files_from_s3:
  cmd.run:
    - name: |
        aws s3 sync {{ grains['s3_bucket'] }} {{ grains['netweaver_inst_folder'] }} \
        --region {{ grains['region'] }} --only-show-errors
    - onlyif: |
        aws s3 sync --dryrun {{ grains['s3_bucket'] }} {{ grains['netweaver_inst_folder'] }} \
        --region {{ grains['region'] }} | grep download > /dev/null 2>&1
    - output_loglevel: quiet
    - hide_output: True

{% endif %}

swpm_folder:
  file.directory:
    - name: {{ grains['netweaver_inst_folder'] }}
    - user: root
    - group: root
    - dir_mode: "0755"
    - file_mode: "0755"
    - recurse:
      - user
      - group
      - mode

{% endif %}
