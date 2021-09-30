{% if grains['os_family'] == 'Suse' %}

{% if grains['ha_sap_deployment_repo'] %}
{% if 'SLE_' in grains['ha_sap_deployment_repo'] %}
{% set repository = grains['ha_sap_deployment_repo'] %}
{% else %}
{% set sle_version = 'SLE_'~grains['osrelease_info'][0] %}
{% set sle_version = sle_version~'_SP'~grains['osrelease_info'][1] if grains['osrelease_info']|length > 1 else sle_version %}
{% set repository = grains['ha_sap_deployment_repo']~"/"~sle_version %}
{% endif %}
allow_all_vendor_changes:
  file.append:
    - name: /etc/zypp/zypp.conf
    - text: solver.allowVendorChange = true

ha_sap_deployments_repo:
  pkgrepo.managed:
    - name: ha_sap_deployments
    - baseurl: {{ repository }}

set_priority_ha_sap_deployments_repo:
  cmd.run:
    - name: zypper mr -p 90 ha_sap_deployments
    - require:
      - ha_sap_deployments_repo
{% endif %}

refresh_repos_after_registration:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - retry:
        attempts: 3
        interval: 15
    - onlyif: 'zypper lr'

{% endif %}
