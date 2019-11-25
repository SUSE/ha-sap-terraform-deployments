habootstrap-formula:
  pkg.installed:
    - retry:
        attempts: 3
        interval: 15

{% if grains['provider'] == 'azure' %}
socat:
  pkg.installed:
    - retry:
        attempts: 3
        interval: 15
{% endif %}
