{% if grains.get('offline_mode') %}
{% if grains['pythonversion'][0] == 2 %}
python-shaptools:
{% else %}
python3-shaptools:
{% endif %}
  pkg.installed:
    - resolve_capabilities: true
    - retry:
        attempts: 3
        interval: 15
{% endif %}

saphanabootstrap-formula:
  pkg.installed:
    - retry:
        attempts: 3
        interval: 15
