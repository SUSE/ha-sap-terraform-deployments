iscsi-formula:
  pkg.installed:
    - retry:
        attempts: 3
        interval: 15
