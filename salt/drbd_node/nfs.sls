# create_nfs_folder_netweaver:
#   file.directory:
#     - name: {{ grains['nfs_mounting_point_netweaver'] }}
#     - user: root
#     - mode: "0755"
#     - makedirs: True

# configure_nfs_netweaver:
#   nfs_export.present:
#     - name: {{ grains['nfs_mounting_point_netweaver'] }}
#     - hosts: '*'
#     - options:
#       - rw
#       - no_root_squash
#       - no_subtree_check
#       - fsid=0
#       - crossmnt
#     - require:
#       - create_nfs_folder_netweaver

# create_nfs_folder_hana:
#   file.directory:
#     - name: {{ grains['nfs_mounting_point_hana'] }}
#     - user: root
#     - mode: "0755"
#     - makedirs: True

# configure_nfs_hana:
#   nfs_export.present:
#     - name: {{ grains['nfs_mounting_point_hana'] }}
#     - hosts: '*'
#     - options:
#       - rw
#       - no_root_squash
#       - no_subtree_check
#       - fsid=1
#       - crossmnt
#     - require:
#       - create_nfs_folder_hana
