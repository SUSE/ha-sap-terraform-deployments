{% if grains['provider'] == 'aws' %}
download_files_from_s3:
  cmd.run:
    - name: "aws s3 sync {{ grains['hana_inst_master'] }} {{ grains['hana_inst_folder'] }} --region {{ grains['region'] }} --only-show-errors"
    - onlyif: "aws s3 sync --dryrun {{ grains['hana_inst_master'] }} {{ grains['hana_inst_folder'] }} --region {{ grains['region'] }} | grep download"
    - output_loglevel: quiet
    - hide_output: True

{% elif grains['provider'] == 'gcp' %}

{% set hana_inst_disk_device = salt['cmd.run']('realpath '~grains['hana_inst_disk_device']) %}
hana_inst_partition:
  cmd.run:
    - name: |
        /usr/sbin/parted -s {{ hana_inst_disk_device }} mklabel msdos && \
        /usr/sbin/parted -s {{ hana_inst_disk_device }} mkpart primary ext2 1M 100% && sleep 1 && \
        /sbin/mkfs -t xfs {{ hana_inst_disk_device }}1
    - unless: ls {{ hana_inst_disk_device }}1
    - require:
      - pkg: parted

hana_inst_directory:
  file.directory:
    - name: {{ grains['hana_inst_folder'] }}
    - user: root
    - mode: "0755"
    - makedirs: True
  mount.mounted:
    - name: {{ grains['hana_inst_folder'] }}
    - device: {{ hana_inst_disk_device }}1
    - fstype: xfs
    - mkmnt: True
    - persist: True
    - opts:
      - defaults
    - require:
      - cmd: hana_inst_partition


{% from 'macros/download_from_google_storage.sls' import download_from_google_storage with context %}

{{ download_from_google_storage(
  grains['gcp_credentials_file'],
  grains['hana_inst_master'],
  grains['hana_inst_folder']) }}

{% endif %}

{{ grains['hana_inst_folder'] }}:
  file.directory:
    - user: root
    - group: root
    - dir_mode: "0755"
    - file_mode: "0755"
    - recurse:
      - user
      - group
      - mode
