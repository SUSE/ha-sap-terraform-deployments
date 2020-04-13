{% if grains.get('devel_mode') %}
allow_all_vendor_changes:
  file.append:
    - name: /etc/zypp/zypp.conf
    - text: solver.allowVendorChange = true
{% endif %}

{% if 'SLE_' in grains['ha_sap_deployment_repo'] %}
{% set repository = grains['ha_sap_deployment_repo'] %}
{% else %}
{% set sle_version = 'SLE_'~grains['osrelease_info'][0] %}
{% set sle_version = sle_version~'_SP'~grains['osrelease_info'][1] if grains['osrelease_info']|length > 1 else sle_version %}
{% set repository = grains['ha_sap_deployment_repo']~"/"~sle_version %}
{% endif %}

ha-factory-repo:
  pkgrepo.managed:
    - name: ha-factory
    - baseurl: {{ repository }}
    - gpgautoimport: True
    # Reduce the ha-factory priority in order to install HA packages from there
    {% if grains.get('devel_mode') %}
    - priority: 98
    {% else %}
    - priority: 110
    {% endif %}
    - refresh: True
    - retry:
        attempts: 3
        interval: 15
