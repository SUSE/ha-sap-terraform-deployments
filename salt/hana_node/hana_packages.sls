{% if (grains['os_family'] == 'Suse') and (grains['osmajorrelease'] == '12') %}
python-shaptools:
{% else %}
python3-shaptools:
{% endif %}
  pkg.installed:
    - fromrepo: saphana

salt-saphana:
  pkg.installed:
    - fromrepo: saphana

saphanabootstrap-formula:
  pkg.installed:
    - fromrepo: saphana

{% if grains['test_usage'] is sameas false %}
#required packages to install SAP HANA, maybe they are already installed in the
#used SLES4SAP distros
numactl:
  pkg.installed

libltdl7:
  pkg.installed

#this package should be installed in saphanabootstrap-formula
netcat-openbsd:
  pkg.installed
{% endif %}
