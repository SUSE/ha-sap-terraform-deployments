{% if grains['qa_mode']|default(false) is sameas true %}
{% if grains['pythonversion'][0] == 2 %}
python2-shaptools:
{% else %}
python3-shaptools:
{% endif %}
  pkg.installed
{% endif %}

saphanabootstrap-formula:
  pkg.installed:
    - fromrepo: ha-factory
