{% if grains['os_family'] == 'Suse' %}

# Workaround for the 'Script died unexpectedly' error bsc#1158664
# If it is a PAYG image, it will force a new registration before refreshing.
# Also the pure refresh will not be executed as salt will still report failure.
# See: https://github.com/saltstack/salt/issues/16291
workaround_payg_cleanup:
  cmd.run:
    - name: |
        rm -f /etc/SUSEConnect &&
        rm -f $(ls /etc/zypp/{repos,services,credentials}.d/* | grep -v -e 'ha-factory') &&
        rm -f /usr/lib/zypp/plugins/services/* &&
        sed -i '/^# Added by SMT reg/,+1d' /etc/hosts
    - onlyif: 'test -e /usr/sbin/registercloudguest'

workaround_payg_new_register:
  cmd.run:
    - name: /usr/sbin/registercloudguest --force-new
    - retry:
        attempts: 3
        interval: 15
    - onlyif: 'test -e /usr/sbin/registercloudguest'

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
    - refresh: False
{% endif %}

refresh_repos_after_registration:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys refresh
    - retry:
        attempts: 3
        interval: 15
    - onlyif: 'zypper lr'

{% if not grains.get('qa_mode') %}
update_system_packages:
  cmd.run:
    - name: zypper --non-interactive --gpg-auto-import-keys --no-recommends --auto-agree-with-licenses update
    - retry:
        attempts: 3
        interval: 15
{% endif %}

{% endif %}
