habootstrap-formula:
  pkg.installed:
    - fromrepo: saphana
    - require:
      - add-saphana-repo

crmsh:
  pkg.installed
