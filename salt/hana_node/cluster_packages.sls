habootstrap-formula:
  pkg.installed:
    - fromrepo: saphana
    - require:
      - add-saphana-repo

crmsh:
  pkg.installed

ha-cluster-bootstrap:
  pkg.installed

hawk2:
  pkg.installed

SAPHanaSR:
  pkg.installed
