{% if grains['qa_mode']|default(false) is sameas true %}
{% if (grains['os_family'] == 'Suse') and (grains['osmajorrelease'] == 12) %}
{% set python2_prefix = 'python' %}
{% else %}
{% set python2_prefix = 'python2' %}
{% endif %}

{% if grains['pythonversion'][0] == 2 %}
{{ python2_prefix }}-shaptools:
{% else %}
python3-shaptools:
{% endif %}
  pkg.installed
{% endif %}

saphanabootstrap-formula:
  pkg.installed:
    - fromrepo: ha-factory
