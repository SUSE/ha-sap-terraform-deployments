drbd-kmp-default:
  pkg.installed:
    - retry:
        attempts: 3
        interval: 15

drbd-formula:
  pkg.installed:
    - retry:
        attempts: 3
        interval: 15

parted_package:
  pkg.installed:
    - name: parted
    - retry:
        attempts: 3
        interval: 15

nfs_packages:
  pkg.installed:
    - name: nfs-kernel-server
    - retry:
        attempts: 3
        interval: 15
