habootstrap-formula:
  pkg.installed:
    - fromrepo: ha-factory
    - retry:
        attempts: 3
        interval: 15
