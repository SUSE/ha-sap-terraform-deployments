{% if grains['additional_packages'] %}
install_additional_packages:
  pkg.latest:
    - pkgs:
{% for package in grains['additional_packages'] %}
      - {{ package }}
{% endfor %}
    - require:
      - sls: repos
{% endif %}
