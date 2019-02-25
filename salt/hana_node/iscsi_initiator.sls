/etc/iscsi/initiatorname.iscsi:
  file.replace:
    - pattern: "^InitiatorName=.*"
    - repl: "InitiatorName=iqn.aws.compute.eu-central-1.{{ grains['server_id'] }}.suse.qa"

/etc/iscsi/iscsid.conf:
  file.replace:
    - pattern: "^node.startup = manual"
    - repl: "node.startup = automatic"

wait-for-iscsi_server:
  cmd.run:
    - name: until nc -z {{ grains['iscsi_srv_ip'] }} 3260;do sleep 2; done
    - timeout: 300

iscsid:
  service.running:
    - enable: True
    - require:
      - cmd: wait-for-iscsi_server

iscsi_discovery:
  cmd.run:
    - name: iscsiadm -m discovery -t st -p "{{ grains['iscsi_srv_ip'] }}:3260" -l -o new
    - onchanges:
      - service: iscsid
