create_nfs_folder:
  file.directory:
    - name: {{ grains['nfs_mounting_point'] }}
    - user: root
    - mode: "0755"
    - makedirs: True


configure_nfs:
  nfs_export.present:
    - name: {{ grains['nfs_mounting_point'] }}
    - hosts: '*'
    - options:
      - rw
      - no_root_squash
      - fsid=0
      - no_subtree_check
    - require:
      - create_nfs_folder
