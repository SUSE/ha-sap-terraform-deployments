saphanabootstrap-formula:
  pkg.installed:
    - fromrepo: ha-factory
    - require:
      - ha-factory-repo
