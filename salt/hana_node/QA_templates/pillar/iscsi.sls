iscsi:
  isns:
    enabled: False
  initiator:
    iscsid:
      myconf:
        node.startup: automatic
        'iqn.aws.compute.eu-central-1.{{ grains['server_id'] }}.suse.qa':
          targetAddress: {{ grains['iscsi_srv_ip'] }}
