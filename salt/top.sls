base:
  'role:hana_node':
    - match: grain
    - hana

  'G@role:hana_node and G@ha_enabled:true':
    - match: compound
    - cluster

  'role:majority_maker_node':
    - match: grain
    - hana.packages
    - hana.ha_cluster
    - cluster

  'role:drbd_node':
    - match: grain
    - drbd
    - cluster

  'role:netweaver_node':
    - match: grain
    - netweaver

  'G@role:netweaver_node and G@ha_enabled:true and P@hostname:.*(01|02)':
    - match: compound
    - cluster

predeployment:
  '*':
    - default

  'role:hana_node':
    - match: grain
    - cluster_node
    - hana_node

  'role:majority_maker_node':
    - match: grain
    - cluster_node
    - majority_maker_node

  'role:netweaver_node':
    - match: grain
    - cluster_node
    - netweaver_node

  'role:drbd_node':
    - match: grain
    - cluster_node
    - drbd_node

  'role:iscsi_srv':
    - match: grain
    - iscsi_srv

  'role:monitoring_srv':
    - match: grain
    - monitoring_srv

  'role:bastion':
    - match: grain
    - bastion

# minimal NFS server on libvirt/openstack - should not be used for production
  'role:nfs_srv':
    - match: grain
    - nfs_srv

postdeployment:
  '*':
    - postdeployment
