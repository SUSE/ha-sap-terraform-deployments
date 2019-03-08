{% if grains['qa_mode']|default(false) is sameas true %}
{% if (grains['os_family'] == 'Suse') and (grains['osmajorrelease'] == '12') %}
python-shaptools:
{% else %}
python3-shaptools:
{% endif %}
  pkg.installed:
    - fromrepo: saphana
{% endif %}

saphanabootstrap-formula:
  pkg.installed:
    - fromrepo: saphana
