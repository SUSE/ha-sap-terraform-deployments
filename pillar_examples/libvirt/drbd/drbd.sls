drbd:
  ## Install required package to manage DRBD
  #install_packages: false

  ## Install required package to configure DRBD in pacemaker cluster
  #with_ha: false

  ## Pirmary node when promoting DRBD
  ## TODO: Only support single primary currently
  promotion: "<HOSTNAME>"

  ## Resource template for /etc/drbd.d/xxx.res
  #res_template: "res_single_vol_v9.j2"

  ## Perform initial sync for DRBD resources
  #need_init_sync: true

  ## Optional: interval check time for waiting for resource synced
  #sync_interval: 10

  ## Optional: timeout for waiting for resource synced
  #sync_timeout: 500

  ## Optional: format the DRBD resource after initial resync
  #need_format: true


  ## Configures some "global" parameters of /etc/drbd.d/global_common.conf
  #global:
  #  # Optional: Participate in DRBD's online usage counter
  #  usage_count: "no"
  #  # Optional: A sizing hint for DRBD to right-size various memory pools.
  #  minor_count: 9
  #  # Optional: The user dialog redraws the second count every time seconds
  #  dialog_refresh: 1


  ## Configures some "common" parameters of /etc/drbd.d/global_common.conf
  #common:
  #  # This section is used to fine tune the behaviour of the resource object
  #  options:
  #    # Optional: Cluster partition requires quorum to modify the replicated data set.
  #    quorum: "off"

  #  # This section is used to fine tune DRBD's properties.
  #  net:
  #    # Optional: you may assign the primary role to both nodes.
  #    multi_primaries: "no"
  #    # Optional: preventive measures to avoid situations where both nodes are primary and disconnected(AKA split brain)
  #    fencing: "resource-and-stonith"
  #    # Optional: split brain handler when no primary
  #    after_sb_0pri: "discard-zero-changes"
  #    # Optional: split brain handler when one primary
  #    after_sb_1pri: "discard-secondary"
  #    # Optional: split brain handler when two primaries
  #    after_sb_2pri: "disconnect"

  #  # Define handlers (executables) that are started by the DRBD system in response to certain events.
  #  handlers:
  #    # Optional: This handler is called in case the node needs to fence the peer's disk
  #    fence_peer: "/usr/lib/drbd/crm-fence-peer.9.sh"
  #    # Optional: This handler is called in case the node needs to unfence the peer's disk
  #    unfence_peer: "/usr/lib/drbd/crm-unfence-peer.9.sh"
  #    # Optional: This handler is called before a resync begins on the node that becomes resync target.
  #    before_resync_target: "/usr/lib/drbd/snapshot-resync-target-lvm.sh -p 15 -- -c 16k"
  #    # Optional: This handler is called after a resync operation finished on the node.
  #    after_resync_target: "/usr/lib/drbd/unsnapshot-resync-target-lvm.sh"
  #    # Optional: DRBD detected a split brain situation but remains unresolved. This handler should alert someone.
  #    split_brain: "/usr/lib/drbd/notify-split-brain.sh root"


  resource:
    - name: "<RESOURCE_NAME_1>"
      device: "<DRBD_DEVICE_1>"
      disk: "<BACKEND_DEVICE_1>"

      # Salt specific
      file_system: "ext3"
      mount_point: "<MOUNT_1>"
      virtual_ip: "<VIRTUAL_IP_1>"

      nodes:
        - name: "<HOSTNAME_1>"
          ip: "<IP_1>"
          port: <PORT_1>
          id: 1
        - name: "<HOSTNAME_2>"
          ip: "<IP_2>"
          port: <PORT_1>
          id: 2
        - name: "<HOSTNAME_3>"
          ip: "<IP_3>"
          port: <PORT_1>
          id: 3

    - name: "<RESOURCE_NAME_2>"
      device: "<DRBD_DEVICE_2>"
      disk: "<BACKEND_DEVICE_2>"

      # Salt specific
      file_system: "ext4"
      mount_point: "<MOUNT_2>"
      virtual_ip: "<VIRTUAL_IP_2>"

      nodes:
        - name: "<HOSTNAME_1>"
          ip: "<IP_1>"
          port: <PORT_2>
          id: 1
        - name: "<HOSTNAME_2>"
          ip: "<IP_2>"
          port: <PORT_2>
          id: 2
        - name: "<HOSTNAME_3>"
          ip: "<IP_3>"
          port: <PORT_2>
          id: 3
