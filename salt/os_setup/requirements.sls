{% if grains['pkg_requirements'] and not grains['ha_sap_deployment_repo'] %}
install_package_requirements:
  pkg.installed:
    - pkgs:
{% for package in grains['pkg_requirements'] %}
      - {{ package }}
{% endfor %}
    - retry:
        attempts: 3
        interval: 15

print_warning_message:
  test.show_notification:
    - text: |
        Some of the previous packages with the specific version are not available.
        If the error persists try to set 'ha_sap_deployment_repo' value in your terraform.tfvars to
        https://download.opensuse.org/repositories/network:ha-clustering:sap-deployments:${specificversion}
    - onfail:
      - pkg: install_package_requirements
{% endif %}
