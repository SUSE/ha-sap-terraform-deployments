drbd:
  promotion: {{ grains['name_prefix'] }}01
  resource:
    - name: "sapdata"
      device: "/dev/drbd1"
      disk: {{ grains['drbd_disk_device'] }}1

      file_system: "xfs"
      mount_point: "/mnt/sapdata/HA1"
      virtual_ip: {{ ".".join(grains['host_ip'].split('.')[0:-1]) }}.201

      nodes:
        - name: {{ grains['name_prefix'] }}01
          ip: {{ grains['host_ips'][0] }}
          port: 7990
          id: 1
        - name: {{ grains['name_prefix'] }}02
          ip: {{ grains['host_ips'][1] }}
          port: 7990
          id: 2
