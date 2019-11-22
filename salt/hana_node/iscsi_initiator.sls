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
    - watch:
      - file: /etc/iscsi/iscsid.conf
      - file: /etc/iscsi/initiatorname.iscsi

iscsi_discovery:
  cmd.run:
    - name: until iscsiadm -m discovery -t st -p "{{ grains['iscsi_srv_ip'] }}:3260" -l -o new;do sleep 10;done
    - output_loglevel: quiet
    - hide_output: True
    - timeout: 2400
    - onchanges:
      - service: iscsid

# Workaround to avoid issue with iscsi initiator
# iscsid: Kernel reported iSCSI connection 2:0 error (1020 - ISCSI_ERR_TCP_CONN_CLOSE: TCP connection closed) state (3)
restart_iscsid:
  service.running:
    - name: iscsid
    - enable: True
    - watch:
      - iscsi_discovery
