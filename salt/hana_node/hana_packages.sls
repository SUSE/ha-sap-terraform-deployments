saphanabootstrap-formula:
  pkg.installed:
    - fromrepo: saphana
    - require:
      - add-saphana-repo
