{% if grains['provider'] == 'azure' %}
python3-azure-identity:
  pkg.installed:
    - retry:
        attempts: 3
        interval: 15
{% endif %}
