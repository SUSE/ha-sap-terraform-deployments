habootstrap-formula:
  pkg.installed:
    - retry:
        attempts: 3
        interval: 15

install_cluster_packages_prepare:
  pkg.installed:
    - pkgs:
      - pacemaker
      - crmsh
      - ha-cluster-bootstrap
      - hawk2

