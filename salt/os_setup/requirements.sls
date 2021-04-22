{% if grains['pkg_requirements'] %}
{% for role, packages in grains['pkg_requirements'].items() if role == grains['role'] %}
install_package_requirements_{{ role }}:
  pkg.installed:
    - pkgs:
      {% for pkg, version in packages.items() %}
      - {{ pkg }}{% if version %}: {{ version }} {% endif %}
      {% endfor %}
    - retry:
        attempts: 3
        interval: 15

print_warning_message_{{ role }}:
  test.show_notification:
    - text: |
        Some of the previous packages with the specific version are not available.
        If the error persists try to set 'ha_sap_deployment_repo' value in your terraform.tfvars to
        https://download.opensuse.org/repositories/network:ha-clustering:sap-deployments:${specificversion}
    - onfail:
      - install_package_requirements_{{ role }}
{% endfor %}
{% endif %}
