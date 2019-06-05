{% if grains['provider'] == 'aws' %}
download_files_from_s3:
  cmd.run:
    - name: "aws s3 sync {{ grains['hana_inst_master'] }}
      {{ grains['hana_inst_folder'] }} --only-show-errors --region {{ grains['region'] }}"
    - onlyif: "aws s3 sync --dryrun {{ grains['hana_inst_master'] }}
      {{ grains['hana_inst_folder'] }} --region {{ grains['region'] }} | grep download"
    - output_loglevel: quiet
    - hide_output: True

{% elif grains['provider'] == 'gcp' %}

hana_inst_partition:
  cmd.run:
    - name: /usr/sbin/parted -s {{grains['hana_inst_disk_device']}} mklabel msdos && /usr/sbin/parted -s {{grains['hana_inst_disk_device']}} mkpart primary ext2 1M 100% && sleep 1 && /sbin/mkfs -t xfs {{grains['hana_inst_disk_device']}}1
    - unless: ls {{ grains['hana_inst_disk_device'] }}1
    - require:
      - pkg: parted

hana_inst_directory:
  file.directory:
    - name: {{ grains['hana_inst_folder'] }}
    - user: root
    - mode: 755
    - makedirs: True
  mount.mounted:
    - name: {{ grains['hana_inst_folder'] }}
    - device: {{ grains['hana_inst_disk_device'] }}1
    - fstype: xfs
    - mkmnt: True
    - persist: True
    - opts:
      - defaults
    - require:
      - cmd: hana_inst_partition

install_rclone:
  cmd.run:
    - name: "curl https://rclone.org/install.sh | sudo bash"

configure_rclone:
  file.append:
    - name: /root/.rclone.conf
    - source: /root/salt/hana_node/files/rclone/gcp.conf

download_files_from_gcp:
  cmd.run:
    - name: "rclone copy remote:{{ grains['sap_hana_deployment_bucket'] }}
      {{ grains['hana_inst_folder'] }}"
{% endif %}

{{ grains['hana_inst_folder'] }}:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 754
    - file_mode: 755
    - recurse:
      - user
      - group
      - mode
