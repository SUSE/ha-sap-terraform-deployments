xfsprogs_package:
  pkg.installed:
    - name: xfsprogs
    - retry:
        attempts: 3
        interval: 15

lvm2_package:
  pkg.installed:
    - name: lvm2
    - retry:
        attempts: 3
        interval: 15

nfs_packages:
  pkg.installed:
    - name: nfs-kernel-server
    - retry:
        attempts: 3
        interval: 15
