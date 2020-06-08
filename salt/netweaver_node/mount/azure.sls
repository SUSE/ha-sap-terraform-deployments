{% if grains['additional_lun'] is not none %}
{% set lun_disk = salt['cmd.run']('readlink /dev/disk/azure/scsi1/lun'~grains['additional_lun']).split('/')[-1] %}
{% set real_path = '/dev/'~lun_disk %}
{% set part_path = real_path~'1' %}

run_fdisk:
  cmd.run:
    - name: echo -e "n\np\n1\n\n\nw" | fdisk {{ real_path }}
    - unless: blkid {{ part_path }}

format_disk:
  cmd.run:
    - name: /sbin/mkfs -t xfs {{ part_path }}
    - unless: blkid {{ part_path }} | grep ' \+\UUID'
    - require:
      - run_fdisk

# This state mounts the new disk using the UUID, as we need to get this value running blkid after the
# previous command, we need to run it as a new state execution
mount_{{ real_path }}:
  module.run:
    - state.sls:
      - mods:
        - hana_node.mount.mount_uuid
      - pillar:
          data:
            device: {{ part_path }}
            path: /usr/sap
            fstype: xfs
    - require:
      - format_disk
{% endif %}
