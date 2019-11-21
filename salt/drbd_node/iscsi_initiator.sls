open-iscsi:
  pkg.installed:
  - retry:
    attempts: 3
    interval: 15

/etc/iscsi/initiatorname.iscsi:
  file.replace:
    - pattern: "^InitiatorName=.*"
    - repl: "InitiatorName=iqn.{{ grains['server_id'] }}.suse.qa"

/etc/iscsi/iscsid.conf:
  file.replace:
    - pattern: "^node.startup = manual"
    - repl: "node.startup = automatic"

iscsid:
  service.running:
    - enable: True

iscsi_discovery:
  cmd.run:
    - name: until iscsiadm -m discovery -t st -p "{{ grains['iscsi_srv_ip'] }}:3260" -l -o new;do sleep 10;done
    - output_loglevel: quiet
    - hide_output: True
    - timeout: 2400
    - onchanges:
      - service: iscsid
