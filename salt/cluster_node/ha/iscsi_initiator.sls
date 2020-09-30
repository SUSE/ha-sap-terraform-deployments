open-iscsi:
  pkg.installed:
  - retry:
      attempts: 3
      interval: 15

lsscsi:
  pkg.installed:
  - retry:
      attempts: 3
      interval: 15

{% if grains['osrelease_info'][0] > 15 or (grains['osrelease_info'][0] == 15 and grains['osrelease_info']|length > 1 and grains['osrelease_info'][1] >= 2) %}
# We cannot use service.running as this systemd unit will stop after being executed
# It is used only to create the initiatorname.iscsi file
start_iscsi_init:
  module.run:
    - service.start:
      - name: iscsi-init
{% endif %}

/etc/iscsi/initiatorname.iscsi:
  file.replace:
    - pattern: "^InitiatorName=.*"
    - repl: "InitiatorName=iqn.{{ grains['hostname'] }}.{{ grains['server_id'] }}.suse"

/etc/iscsi/iscsid.conf:
  file.replace:
    - pattern: "^node.startup = manual"
    - repl: "node.startup = automatic"

iscsi-queue-depth:
  file.replace:
    - name: "/etc/iscsi/iscsid.conf"
    - pattern: "^node.session.queue_depth = [0-9]*"
    - repl: "node.session.queue_depth = 64"

iscsi:
  service.running:
    - enable: True
    - watch:
      - file: /etc/iscsi/iscsid.conf
      - file: /etc/iscsi/initiatorname.iscsi

iscsi_discovery:
  cmd.run:
    - name: until iscsiadm -m discovery -t st -p "{{ grains['iscsi_srv_ip'] }}:3260" -l -o new;do sleep 10;done
    - unless: iscsiadm -m session
    - output_loglevel: quiet
    - hide_output: True
    - timeout: 2400
    - require:
      - iscsi

iscsid:
  service.running:
    - watch:
      - cmd: iscsi_discovery

# Wait until the disk id is displayed in the lsscsi command, as `-` is displayed at the beginning sometimes
{% set sbd_disk_id_pattern = '/^\[[0-9]\:[0-9]\:[0-9]\:'~grains['sbd_lun_index']~'\].*/' %}

wait_disk_id_available:
  cmd.run:
    - name: until [ "$(lsscsi -i | grep "LIO-ORG" | awk "{{ sbd_disk_id_pattern }}{print \$NF }")" != "-" ];do sleep 3;done
    - output_loglevel: quiet
    - timeout: 120
    - require:
      - lsscsi
      - iscsi_discovery

# This state sets the sbd_disk grain value. As we cannot run the lssci command directly to get the output (the output is change in the latest command)
# this workaround that scenario to render the output during execution time
set_grains_sbd_disk_device:
  module.run:
    - state.sls:
      - mods:
        - cluster_node.ha.sbd
    - require:
      - lsscsi
      - iscsi_discovery
      - wait_disk_id_available
