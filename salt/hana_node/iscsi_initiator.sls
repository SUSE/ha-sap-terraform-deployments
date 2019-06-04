open-iscsi:
  pkg.installed

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
    - timeout: 15000
    - onchanges:
      - service: iscsid
