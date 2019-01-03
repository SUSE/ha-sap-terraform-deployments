add-saphana-repo:
  pkgrepo.managed:
    - name: saphana
    - baseurl: https://download.opensuse.org/repositories/home:xarbulu:sap-deployment/SLE_12_SP4/
    - gpgautoimport: True

python-shaptools:
  pkg.installed:
    - fromrepo: saphana
    - require:
      - add-saphana-repo

salt-saphana:
  pkg.installed:
    - fromrepo: saphana
    - require:
      - add-saphana-repo

saphanabootstrap-formula:
  pkg.installed:
    - fromrepo: saphana
    - require:
      - add-saphana-repo
