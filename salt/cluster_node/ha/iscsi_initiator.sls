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
    - output_loglevel: quiet
    - hide_output: True
    - timeout: 2400
    - require:
      - iscsi

iscsid:
  service.running:
    - watch:
      - cmd: iscsi_discovery

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
